class Route
  include MongoMapper::Document

  key :incoming_path, String
  key :route_type, String
  key :handler, String
  key :backend_id, String

  ensure_index [[:incoming_path, 1], [:route_type, 1]], :unique => true

  validates :incoming_path, :presence => true, :uniqueness => {:scope => :route_type}
  validates :route_type, :inclusion => {:in => %w(prefix exact)}
  validates :handler, :inclusion => {:in => %w(backend)}
  validates :backend_id, :presence => true

  scope :backend, where(:handler => "backend")
end
