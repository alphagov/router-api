Rails.application.config.generators do |g|
  g.orm :mongo_mapper
  g.view_specs false
  g.helper false
  g.assets false
end
