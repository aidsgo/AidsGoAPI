require 'uri'
require 'net/http'
require 'json'

class WildDogConnector

  def initialize
    @wilddog_url = 'https://bestaidsgo.wilddogio.com/data'
  end

  def add_new_incidents emergency_id
    current_incidents = get_current_incident
    if current_incidents.nil?
      updated_incidents = {"activeIncidents" => {emergency_id => {"id" => emergency_id}}}
      send_put_request "#{@wilddog_url}.json", updated_incidents.to_json
    else
      updated_incidents = current_incidents.merge({emergency_id => {"id" => emergency_id}})
      send_put_request "#{@wilddog_url}/activeIncidents.json", updated_incidents.to_json
    end
  end

  def add_volunteer_to_incident emergency_id, volunteer_id
    current_volunteers = get_current_incident_volunteers emergency_id
    if current_volunteers.nil?
      updated_volunteers = {"volunteers" =>[volunteer_id]}
      send_put_request "#{@wilddog_url}/activeIncidents/#{emergency_id}.json", updated_volunteers.to_json
    else
      current_volunteers_array = transfer_hash_to_array(current_volunteers)
      return if current_volunteers_array.include? volunteer_id
      updated_volunteers = current_volunteers_array.push(volunteer_id)
      send_put_request "#{@wilddog_url}/activeIncidents/#{emergency_id}/volunteers.json", updated_volunteers.to_json
    end
  end

  def resolve_incident

  end


  private

  def get_current_incident
    "#{@wilddog_url}/activeIncidents.json"
    resp = send_get_request "#{@wilddog_url}/activeIncidents.json"
    JSON.load(resp.body)
  end

  def get_current_incident_volunteers emergency_id
    resp = send_get_request "#{@wilddog_url}/activeIncidents/#{emergency_id}/volunteers.json"
    JSON.load(resp.body)
  end


  def send_get_request url
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    get_request = Net::HTTP::Get.new(uri.request_uri)
    http.request(get_request)
  end

  def send_put_request url, data
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    put_request = Net::HTTP::Put.new(uri.request_uri)
    put_request.body = data
    http.request(put_request)
  end

  def transfer_hash_to_array input_hash
    input_hash.values
  end

end

