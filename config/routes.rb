Rails.application.routes.draw do
  with_options format: false do |r|
    r.resources :backends, only: %i[show update destroy]

    r.get "/routes" => "routes#show"
    r.put "/routes" => "routes#update"
    r.delete "/routes" => "routes#destroy"
    r.post "/routes/commit" => "routes#commit"

    r.get "/healthcheck" => proc { [200, {}, %w[OK]] }
  end
end
