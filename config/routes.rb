# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
#get 'traces/home', :to => 'traces_home#index'
get '/projects/:project_id/traces', :to => 'traces_home#index'
get '/projects/:project_id/next', :to => 'traces_home#pages'
get '/projects/:project_id/previous', :to => 'traces_home#pages'
