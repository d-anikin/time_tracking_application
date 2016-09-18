namespace :tta do
  post :session, :to => 'session#create'
  delete :session, :to => 'session#destroy'
  get :idle, :to => 'session#idle'
  get :issues, :to => 'issues#index'
  resources :time_entry, only: [:update] do
    get :idle, on: :collection
    post :start, on: :collection
    put :stop
  end
end
