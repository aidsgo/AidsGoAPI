require_relative '../connectors/wilddog_connector'

class VolunteerController < ApplicationController

  def initialize
    @wd_connector = WildDogConnector.new
  end

  def login
    phone = params[:phone_number]
    pwd = params[:password]

    volunteer = Volunteer.find_by(phone: phone)

    if volunteer && pwd === volunteer.pwd
      token = encrypt_token(phone)
      volunteer.public_key = token

      if volunteer.save
        render json: {message: 'Login successfully', token: token, id: volunteer.id, name: volunteer.name, phone: volunteer.phone}, status: :ok
      else
        login_failed
      end
    else
      login_failed
    end
  end

  def sign_up
    phone = params[:phone_number]
    pwd = params[:password]
    token = encrypt_token phone

    if !user_exists?(phone) && Volunteer.new(phone: phone, pwd: pwd, public_key: token).save
      volunteer = Volunteer.find_by_phone(phone)
      render json: {message: 'Sign up successfully', token: token, id: volunteer.id, name: volunteer.name, phone: volunteer.phone}, status: :created
    else
      render text: 'Already exists', status: :unprocessable_entity
    end
  end

  def accept
    token = request.headers[:Authorization]
    volunteer_id = params[:volunteer_id]

    if auth?(token, volunteer_id)
      emergency = Emergency.find(params[:emergency_id])
      @wd_connector.add_volunteer_to_incident emergency.id, volunteer_id
      accepted_volunteers = emergency.accept
      if accepted_volunteers.nil?
        accepted_volunteers = [volunteer_id]
      else
        accepted_volunteers = accepted_volunteers << volunteer_id unless accepted_volunteers.include?(volunteer_id)
      end
      emergency.update_attributes(accept: accepted_volunteers)

      render nothing: true, status: :ok
    else
      unauthorized_action
    end
  end

  def my_taken_incidents
    token = request.headers[:Authorization]
    volunteer_id = params[:volunteer_id]

    if auth?(token, volunteer_id)
      my_incidents = Emergency.all.select do |emergency|
        emergency.accept.include?(volunteer_id)
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

      render json: results, status: :ok
    else
      unauthorized_action
    end
  end

  def update_resolved
    token = request.headers[:Authorization]
    volunteer_id = params[:volunteer_id]

    if auth?(token, volunteer_id)
      emergency_id = params[:emergency_id]
      emergency = Emergency.find(emergency_id)

      if emergency.resolved.to_s.empty? && emergency.update(resolved: volunteer_id)
        @wd_connector.resolve_incident emergency_id
        # notify_folks(Elder.find(emergency.elder_id), 'Emergency has been resolved by volunteers!')

        render json: emergency, status: :created
      else
        render error: 'Aid resolved fails', status: :unprocessable_entity
      end
    else
      unauthorized_action
    end
  end

  def need_more
    token = request.headers[:Authorization]
    volunteer_id = params[:volunteer_id]
    emergency_id = params[:emergency_id]
    elder_location = params[:current_location]
    elder_id = params[:elder_id]

    if auth?(token, volunteer_id)
      @wd_connector.add_new_incidents emergency_id
      volunteers = nearby_volunteers(elder_location, Elder.find(elder_id))
      render json: {:nearby_volunteers => volunteers}, status: :created
    else
      unauthorized_action
    end
  end

  def show_all
    render json: Volunteer.all
  end

  private

  def login_failed
    render text: 'Login failed', status: :unauthorized
  end

  def auth?(token, volunteer_id)
    Volunteer.find_by(id: volunteer_id, public_key: token)
  end

  def unauthorized_action
    render text: 'Authentication failed', status: :unauthorized
  end

  def encrypt_token(phone)
    rsa_private = OpenSSL::PKey::RSA.generate 2048
    payload = {:phone => phone}
    JWT.encode payload, rsa_private, 'RS256'
  end

  def user_exists?(phone)
    Volunteer.find_by(phone: phone)
  end
end