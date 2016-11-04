# This file should contain all the record creation needed to seed the database with its default values.
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Elder.create(name: 'xiao ming', birthday: '2000/1/1', sex: 'female', community: '天谷八路环普产业园', image: 'http://image.jpg',
             address: '140 Market St, San Francisco, CA', serial_number: 'serial_number 1',
             contact: {phone: '12345678', email: 'asdf@gmail.com', weChat: '12345678'}, help_count: 5,
             emergency_call: {phone: '+8618629453426', email: 'asdf@gmail.com', weChat: '12345678'})


(0..5).each do |index|
  Volunteer.create(name: "name #{index}", birthday: '2000/1/1', sex: 'male', community: '天谷八路环普产业园', image: 'http://image.jpg',
                   contact: {phone: '12345678', email: 'asdf@gmail.com', weChat: '12345678'}, help_count: 5,
                   emergency_call: {phone: '+8615829085945', email: 'asdf@gmail.com', weChat: '12345678'})
end


Emergency.create(elder_id: 1, elder_location: {lat: 34.256403, lng: 108.953661},
                 accept: ['name 0', 'name 1', 'name 2'], reject: ['name 4', 'name 5'],
                 emergency_validation: true)
# Emergency.create(elder_id: 1, elder_location: {lat: 34.256403, lng: 108.953661}, emergency_validation: true)
# Emergency.create(elder_id: 1, elder_location: {lat: 34.256403, lng: 108.953661}, emergency_validation: false)
# Emergency.create(elder_id: 1, elder_location: {lat: 34.256403, lng: 108.953661}, emergency_validation: true)
# Emergency.create(elder_id: 1, elder_location: {lat: 34.256403, lng: 108.953661  }, emergency_validation: true)

