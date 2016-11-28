Rails.application.routes.draw do
  post '/emergency', :to => 'emergency#notify'
  put '/emergency/:action_name', :to => 'emergency#update_action'
  get '/emergencies', :to => 'emergency#show_emergency_list'

  put '/volunteers/:volunteer_id/resolve/:emergency_id', :to => 'volunteer#update_resolved'
  put '/volunteers/:volunteer_id/accept/:emergency_id', :to => 'volunteer#accept'
  get '/volunteers/:volunteer_id/emergencies', :to => 'volunteer#my_taken_incidents'
  get '/volunteers', :to => 'volunteer#show_all'

  put 'volunteers/login', :to => 'volunteer#login'
  post 'volunteers/sign_up', :to => 'volunteer#sign_up'
  post 'volunteers/testing', :to => 'volunteer#testing'

  put 'elders/login', :to => 'elder#login'
  post 'elders/sign_up', :to => 'volunteer#sign_up'
end
