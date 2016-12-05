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
      updated_incidents = {'activeIncidents' => {emergency_id => {'id' => emergency_id}}}
      send_put_request "#{@wilddog_url}.json", updated_incidents.to_json
    else
      updated_incidents = current_incidents.merge({emergency_id => {'id' => emergency_id}})
      send_put_request "#{@wilddog_url}/activeIncidents.json", updated_incidents.to_json
    end
  end

  def add_volunteer_to_incident emergency_id, volunteer_id
    current_volunteers = get_current_incident_volunteers emergency_id
    if current_volunteers.nil?
      updated_volunteers = {'id'=> emergency_id, 'volunteers' =>[volunteer_id]}
      send_put_request "#{@wilddog_url}/activeIncidents/#{emergency_id}.json", updated_volunteers.to_json
    else
      current_volunteers = transfer_hash_to_array(current_volunteers) if current_volunteers.is_a?(Hash)
      return if current_volunteers.include? volunteer_id
      updated_volunteers = current_volunteers.push(volunteer_id)
      send_put_request "#{@wilddog_url}/activeIncidents/#{emergency_id}/volunteers.json", updated_volunteers.to_json
    end
  end

  def resolve_incident emergency_id
    send_delete_request "#{@wilddog_url}/activeIncidents/#{emergency_id}.json"
  end


  private

  def get_current_incident
    "#{@wilddog_url}/activeIncidents.json"
    resp = send_get_request "#{@wilddog_url}/activeIncidents.json"
    JSON.load(resp.body)
  end

  def get_current_incident_volunteers emergency_id
    resp = send_get_request "#{@wilddog_url}/activeIncidents/#{emergency_id}/volunteers.json"
    p resp.body
    JSON.load(resp.body)
  end


  def send_get_request url
    sent_http_request Net::HTTP::Get, url
  end

  def send_put_request url, data
    sent_http_request Net::HTTP::Put, url ,data
  end

  def send_delete_request url
    sent_http_request Net::HTTP::Delete, url
  end

  def transfer_hash_to_array input_hash
    input_hash.values
  end

  def sent_http_request method, url, data = nil
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = method.new(uri.request_uri)
    request.body = data unless data.nil?
    http.request(request)
  end

end

