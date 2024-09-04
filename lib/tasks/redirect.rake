desc "Redirects the coronavirus topical event page to new landing page"
task redirect_coronavirus: :environment do
  old = "/government/topical-events/coronavirus-covid-19-uk-government-response"
  new = "/coronavirus"
  redirect(old, new)
end

def redirect(old_path, new_path)
  Route.create!(
    incoming_path: old_path,
    redirect_to: new_path,
    route_type: "exact",
    handler: "redirect",
    backend_id: "whitehall-frontend",
    segments_mode: "ignore",
  )
end
