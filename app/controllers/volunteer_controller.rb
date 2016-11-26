require_relative '../connectors/wilddog_connector'

class VolunteerController < ApplicationController
  def login
    phone = params[:phone]
    pwd = params[:pwd]

    volunteer = Volunteer.find_by(phone: phone)

    if volunteer && pwd === volunteer.pwd
      rsa_private, rsa_public = encrypt_token
      volunteer.public_key = rsa_public

      if volunteer.save
        payload = {:phone => phone, :pwd => pwd}
        token = JWT.encode payload, rsa_private, 'RS256'

        render json: {message: 'Login successfully', token: token}, status: :ok
      else
        render text: 'Login failed', status: :unauthorized
      end
    else
      render text: 'Login failed', status: :unauthorized
    end
  end

  def sign_up
    rsa_private,rsa_public = encrypt_token

    phone = params[:phone]
    pwd = params[:pwd]

    if !user_exists?(phone) && Volunteer.new(phone: phone, pwd: pwd, public_key: rsa_public).save
      payload = {:phone => phone, :pwd => pwd}
      token = JWT.encode payload, rsa_private, 'RS256'

      render json: {message: 'Sign up successfully', token: token}, status: :created
    else
      render text: 'Already exists', status: :unprocessable_entity
    end
    # decoded_token = JWT.decode token, rsa_public, true, { :algorithm => 'RS256' }
  end

  def show_all
    render json: Volunteer.all
  end

  def accept
    volunteer_id = params[:volunteer_id]
    emergency = Emergency.find(params[:emergency_id])
    WildDogConnector.new.add_volunteer_to_incident emergency.id, volunteer_id
    accepted_volunteers = emergency.accept
    if accepted_volunteers.nil?
      accepted_volunteers = [volunteer_id]
    else
      accepted_volunteers = accepted_volunteers << volunteer_id unless accepted_volunteers.include?(volunteer_id)
    end
    emergency.update_attributes(accept: accepted_volunteers)

    render nothing: true, status: :ok
  end


  def my_taken_incidents
    my_incidents = Emergency.all.select do |emergency|
      emergency.accept.include?(params[:volunteer_id])
    end

    results ={}
    my_incidents.each do |incident|
      emergency_elder = Elder.find(incident.elder_id)
      results.merge!(
        {
          incident.id => {
            id: incident.id,
            name: Elder.find(incident.elder_id).name,
            location: incident.elder_location,
            time: incident.created_at,
            taken: incident.accept,
            resolved: incident.resolved,
            emergency_call: emergency_elder.emergency_call['phone'],
            property_management_company_phone: emergency_elder.emergency_call['pmc_phone']
          }
        }
      )
    end

    render json: results
  end

  def update_resolved
    emergency = Emergency.find(params[:emergency_id])
    if emergency.resolved.to_s.empty? && emergency.update(resolved: params[:volunteer_id])
      @wd_connector.resolve_incident params[:emergency_id]
      # notify_folks(Elder.find(emergency.elder_id), 'Emergency has been resolved by volunteers!')

      render json: emergency, status: :created
    else
      render error: 'Aid resolved fails', status: :unprocessable_entity
    end
  end

  private

  def encrypt_token
    rsa_private = OpenSSL::PKey::RSA.generate 2048
    rsa_public = rsa_private.public_key

    return rsa_private, rsa_public
  end

  def user_exists?(phone)
    Volunteer.find_by(phone: phone)
  end
end