class Elder < ActiveRecord::Base
  def get_nearby_volunteers(self_location, vol_location)
    # Geocoder::Calculations.distance_between(self_location, vol_location, :units => :km) < 300
    true
  end
end
