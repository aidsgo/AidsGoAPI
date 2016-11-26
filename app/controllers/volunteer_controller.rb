require_relative '../connectors/wilddog_connector'

class VolunteerController < ApplicationController
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
end