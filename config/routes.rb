Rails.application.routes.draw do
  post '/emergency/notify', :to => 'emergency#notify'
  post '/emergency/notify/iot', :to => 'emergency#iot_notify'
  get '/emergencies', :to => 'emergency#show_emergency_list'

  put '/volunteers/:volunteer_id/resolve/:emergency_id', :to => 'volunteer#update_resolved'
  put '/volunteers/:volunteer_id/accept/:emergency_id', :to => 'volunteer#accept'
  post '/volunteers/:volunteer_id/need_more/:emergency_id', :to => 'volunteer#accept'
  get '/volunteers/:volunteer_id/emergencies', :to => 'volunteer#my_taken_incidents'
  get '/volunteers', :to => 'volunteer#show_all'

  post 'volunteers/login', :to => 'volunteer#login'
  post 'volunteers/sign_up', :to => 'volunteer#sign_up'

  post 'elders/login', :to => 'elder#login'
  post 'elders/sign_up', :to => 'elder#sign_up'
  put 'elders/update', :to => 'elder#update'
end
