get '/time_tracking_application/details', :to => 'main#details'
get '/time_tracking_application/timelog/start', :to => 'timelog#start'
get '/time_tracking_application/timelog/update', :to => 'timelog#update'
get '/time_tracking_application/timelog/stop', :to => 'timelog#stop'
