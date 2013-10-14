class Route
  include MongoMapper::Document

  key :incoming_path, String
  key :application_id, String
  key :route_type, String

  ensure_index [[:incoming_path, 1], [:route_type, 1]], :unique => true

  validates :application_id, :presence => true
  validates :route_type, :inclusion => {:in => %w(prefix exact)}
  validates :incoming_path, :presence => true, :uniqueness => {:scope => :route_type}
end
