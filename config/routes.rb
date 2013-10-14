RouterApi::Application.routes.draw do

  get "/healthcheck" => proc { [200, {}, ["OK"]] }
end
