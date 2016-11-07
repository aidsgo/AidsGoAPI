class EmergencyController < ApplicationController
  def notify
    injured_elder = params[:serial_number] ? Elder.find_by(serial_number: params[:serial_number]) : Elder.find(params[:elder_id])
    elder_location = params[:current_location] || transfer_location(injured_elder.address)

    if Emergency.new(elder_id: injured_elder.id, elder_location: elder_location, resolved: false).save
      volunteers = nearby_volunteers(elder_location, injured_elder)

      # uncomment this one when production
      # notify_folks(injured_elder, "Emergency is happening!")

      render json: {:nearby_volunteers => volunteers}, status: :created
    else
      render nothing: true
    end
  end

  def my_taken_incidents
    my_incidents = Emergency.all.select do |emergency|
      emergency.accept.include?(params[:volunteer_id])
    end

    results ={}
    my_incidents.each do |incident|
      results.merge!(
        {
          incident.id => {
            id: incident.id,
            name: Elder.find(incident.elder_id).name,
            location: incident.elder_location,
            time: incident.created_at,
            taken: incident.accept,
            resolved: incident.resolved
          }
        }
      )
    end

    render json: results
  end

  def accept
    volunteer_id = params[:volunteer_id]
    emergency = Emergency.find(params[:emergency_id])

    accepted_volunteers = emergency.accept
    accepted_volunteers = accepted_volunteers << volunteer_id unless accepted_volunteers.include?(volunteer_id)
    emergency.update_attributes(accept: accepted_volunteers)

    render :nothing, status :ok
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
    distance = params[:distance] || 500
    volunteer_location = format_locations(eval params[:volunteer_location])

    emergencies = Emergency.all.select do |alert|
      alert.get_nearby_emergencies(volunteer_location, distance)
    end

    results ={}
    emergencies.each do |emergency|
      results.merge!({ emergency.id => {
        id: emergency.id,
        name: Elder.find(emergency.elder_id).name,
        distance: calculate_distance(volunteer_location, emergency.elder_location),
        location: emergency.elder_location,
        time: emergency.created_at,
        taken: emergency.accept,
        resolved: emergency.resolved
      }})
    end

    render json: results
  end

  def update_resolved
    emergency = Emergency.find(params[:emergency_id])
    if emergency.resolve.to_s.empty? && emergency.update(resolved: params[:volunteer_id])

      # notify_folks(Elder.find(emergency.elder_id), 'Emergency has been resolved by volunteers!')

      render json: emergency, status: :created
    else
      render error: 'Aid resolved fails', status: :unprocessable_entity
    end
  end

  def update_action
    action_name = params[:action_name]
    action_column = Emergency.find(params[:emergency_id]).send(action_name.to_sym)
    action_column.push(params[:name])
    emergency = Emergency.find(params[:emergency_id])
    emergency[action_name.to_sym] = action_column

    if emergency.save
      render text: "Aid #{action_name} successfully", status: :created
    else
      render error: "Aid #{action_name} fails", status: :unprocessable_entity
    end
  end

  private
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
end
