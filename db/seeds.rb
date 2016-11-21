# This file should contain all the record creation needed to seed the database with its default values.
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Elder.create(name: '王奶奶', birthday: '2000/1/1', sex: 'female', community: '天谷八路环普产业园', image: 'http://image.jpg',
             address: '140 Market St, San Francisco, CA', serial_number: 'G030JF05435585ES',
             contact: {phone: '12345678', email: 'asdf@gmail.com', weChat: '12345678'}, help_count: 5,
             emergency_call: {phone: '+8618629453426', pmc_phone: '+8618688888888', email: 'asdf@gmail.com', weChat: '12345678'})





(0..5).each do |index|
  Volunteer.create(name: "name #{index}", birthday: '2000/1/1', sex: 'male', community: '天谷八路环普产业园', image: 'http://image.jpg',
                   contact: {phone: '12345678', email: 'asdf@gmail.com', weChat: '12345678'}, help_count: 5,
                   emergency_call: {phone: '+8615829085945', email: 'asdf@gmail.com', weChat: '12345678'})
end


Emergency.create(elder_id: Elder.first.id, elder_location: {lat: 34.256403, lng: 108.953661},
                 accept: [], reject: [],
                 resolved: '')
# Emergency.create(elder_id: 1, elder_location: {lat: 34.256403, lng: 108.953661}, resolved: false)
# Emergency.create(elder_id: 1, elder_location: {lat: 34.256403, lng: 108.953661}, resolved: true)
# Emergency.create(elder_id: 1, elder_location: {lat: 34.256403, lng: 108.953661}, resolved: false)
# Emergency.create(elder_id: 1, elder_location: {lat: 34.256403, lng: 108.953661  }, resolved: false)

