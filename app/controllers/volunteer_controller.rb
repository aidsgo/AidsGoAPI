require_relative '../connectors/wilddog_connector'

class VolunteerController < ApplicationController
  def login
    phone = params[:phone]
    pwd = params[:pwd]

    volunteer = Volunteer.find_by(phone: phone)

    if volunteer && pwd === volunteer.pwd
      token = encrypt_token(phone)
      volunteer.public_key = token

      if volunteer.save
        render json: {message: 'Login successfully', token: token}, status: :ok
      else
        render text: 'Login failed', status: :unauthorized
      end
    else
      render text: 'Login failed', status: :unauthorized
    end
  end

  def sign_up
    phone = params[:phone]
    pwd = params[:pwd]
    token = encrypt_token phone

    if !user_exists?(phone) && Volunteer.new(phone: phone, pwd: pwd, public_key: token).save
      render json: {message: 'Sign up successfully', token: token}, status: :created
    else
      render text: 'Already exists', status: :unprocessable_entity
    end
  end

  def testing
    token = request.headers[:token]
    phone = params[:phone]
    volunteer = Volunteer.find_by(phone: phone, public_key: token)

    if volunteer
      render text: '111', status: :ok
    else
      render text: '222', status: :unauthorized
    end

  end

  def accept
    token = request.headers[:token]
    volunteer_id = params[:volunteer_id]

    if Volunteer.find_by(id: volunteer_id, public_key: token)
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
    else
      render text: 'Authentication failed', status: :unauthorized
    end
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
    emergency_id = params[:emergency_id]
    volunteer_id = params[:volunteer_id]
    emergency = Emergency.find(emergency_id)

    if emergency.resolved.to_s.empty? && emergency.update(resolved: volunteer_id)
      @wd_connector.resolve_incident emergency_id
      # notify_folks(Elder.find(emergency.elder_id), 'Emergency has been resolved by volunteers!')

      render json: emergency, status: :created
    else
      render error: 'Aid resolved fails', status: :unprocessable_entity
    end
  end

  def show_all
    render json: Volunteer.all
  end

  private

  def encrypt_token(phone)
    rsa_private = OpenSSL::PKey::RSA.generate 2048
    payload = {:phone => phone}
    JWT.encode payload, rsa_private, 'RS256'
  end

  def user_exists?(phone)
    Volunteer.find_by(phone: phone)
  end
end