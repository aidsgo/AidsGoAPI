require 'uri'
require 'net/http'
require 'json'
require_relative '../connectors/wilddog_connector'

class EmergencyController < ApplicationController
  PUSH_URL = 'https://api.jpush.cn/v3/push'
  APP_KEY = '7ae6d033056378bf5f352bae'
  MASER_SECRET ='1c9caae6c118a950a90f3cf6'

  def initialize
    @wd_connector = WildDogConnector.new
  end

  def iot_notify
    emergency_notify(Elder.find_by(serial_number: params[:serial_number]))
  end

  def notify
    elder_id = params[:elder_id]
    token = request.headers[:Authorization]

    if auth?(Elder, elder_id, token)
      emergency_notify(Elder.find(elder_id))
    else
      unauthorized_action
    end
  end

  # [
  #   {
  #     id: 1,
  #     name: 'injured people name',
  #     distance: 0.0027571677693187745,
  #     location: {
  #       lat: 34.256403,
  #       lng: 108.953661
  #     },
  #     time: '2016-08-25T09:47:24.963Z',
  #     volunteer: [
  #       'volunteer name 1', 'volunteer name 1', 'volunteer name 1'
  #     ],
  #     reject: true,
  #     taken: true,
  #     resolved: true
  #   }
  # ]
  def show_emergency_list
    volunteer_id = params[:volunteer_id]
    token = request.headers[:Authorization]

    if auth?(Volunteer, volunteer_id, token)
      distance = params[:distance] || 500
      volunteer_location = format_locations(params[:volunteer_location]) unless params[:volunteer_location].present?

      emergencies = Emergency.all.select do |alert|
        volunteer_location.blank? || (!alert.resolved? && alert.get_nearby_emergencies(volunteer_location, distance))
      end

      results ={}
      emergencies.each do |emergency|
        emergency_elder = Elder.find(emergency.elder_id)
        results.merge!({emergency.id => {
          id: emergency.id,
          name: emergency_elder.name,
          distance: volunteer_location.present? ? 'unknown' : calculate_distance(volunteer_location, emergency.elder_location),
          location: emergency.elder_location,
          time: emergency.created_at,
          taken: emergency.accept,
          resolved: emergency.resolved,
          emergency_call: emergency_elder.emergency_call['phone'],
          property_management_company_phone: emergency_elder.emergency_call['pmc_phone']
        }})
      end

      render json: results, status: :ok
    else
      unauthorized_action
    end
  end

  private

  def emergency_notify(injured_elder)
    elder_location = params[:current_location] || transfer_location(injured_elder.address)

    begin
      new_emergency = Emergency.create(elder_id: injured_elder.id, elder_location: elder_location, accept: [], reject: [], resolved: false)
      @wd_connector.add_new_incidents new_emergency.id
      volunteers = nearby_volunteers(elder_location, injured_elder)
      render json: {:nearby_volunteers => volunteers}, status: :created
    rescue => e
      logger.fatal e.message
      render nothing: true
    end
  end

  def auth?(klass, user_id, token)
    klass.find_by(id: user_id, public_key: token)
  end

  def unauthorized_action
    render text: 'Authentication failed', status: :unauthorized
  end

  def emergency_taken?(emergency)
    !emergency.nil? && (emergency.accept.length > 0)
  end

  def format_locations(location)
    [location[:lat], location[:lng]]
  end

  def calculate_distance(current_location, elder_location)
    Geocoder::Calculations.distance_between(current_location, [elder_location['lat'], elder_location['lng']], :units => :km)
  end

  def notify_folks(injured_elder, emergency_msg)
    account_sid = 'ACd2aa2cae113c8e8e4c7f0efc6af83cde'
    auth_token = '5259dc17f07f6e065adc6cf54bcb9ced'
    @client = Twilio::REST::Client.new account_sid, auth_token

    @client.messages.create(
      from: '+16412434301',
      to: injured_elder.emergency_call['phone'],
      body: emergency_msg
    )
  end

  def transfer_location(location)
    coordinates = Geokit::Geocoders::GoogleGeocoder.geocode location

    {
      lat: coordinates.lat,
      lng: coordinates.lng
    }
  end

  def nearby_volunteers(elder_location, injured_elder)
    Volunteer.all.select do |volunteer|
      injured_elder.get_nearby_volunteers(format_locations(elder_location), volunteer.get_location)
    end
  end

  def send_push_notify elder_name
    uri = URI(PUSH_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.basic_auth APP_KEY, MASER_SECRET
    request.body = push_data_generator(elder_name).to_json
    http.request(request)
  end

  def push_data_generator elder_name
    {
      :platform => 'all',
      :audience => 'all',
      :notification => {
        :alert => "#{elder_name} 需要救助!",
      },
      :options => {
        :apns_production => false
      }
    }
  end
end
