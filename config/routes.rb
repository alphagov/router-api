RouterApi::Application.routes.draw do

  resources :backends, :only => [:show, :update]

  get "/healthcheck" => proc { [200, {}, ["OK"]] }, :format => false
end
