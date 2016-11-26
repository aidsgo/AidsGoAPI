Rails.application.routes.draw do
  post '/emergency', :to => 'emergency#notify'
  put '/emergency/:action_name', :to => 'emergency#update_action'
  get '/emergencies', :to => 'emergency#show_emergency_list'

  put '/volunteers/:volunteer_id/resolve/:emergency_id', :to => 'volunteer#update_resolved'
  put '/volunteers/:volunteer_id/accept/:emergency_id', :to => 'volunteer#accept'
  get '/volunteers/:volunteer_id/emergencies', :to => 'volunteer#my_taken_incidents'
  get '/volunteers', :to => 'volunteer#show_all'

  put '/login', :to => 'volunteer_login#login'
  post '/sign_up', :to => 'volunteer_login#sign_up'
end
