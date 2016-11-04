class Emergency < ActiveRecord::Base
  def get_nearby_emergencies(current_location, distance)
    Geocoder::Calculations.distance_between(current_location, [elder_location['lat'], elder_location['lng']], :units => :km) < distance.to_i
  end

  def resolved?
    resolved
  end
end
