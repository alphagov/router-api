RouterApi::Application.routes.draw do

  resources :backends, :only => [:show, :update, :destroy], :format => false

  get "/healthcheck" => proc { [200, {}, ["OK"]] }, :format => false
end
