class Volunteer < ActiveRecord::Base

  #lat lon
  def get_location
    # [rand(34.256403..38.256403), rand(108.953661...110.953661)]
    [37.79363, -122.396116]
  end

end
