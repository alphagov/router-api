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
  with_options :if => :backend? do |be|
    be.validates :backend_id, :presence => true
    be.validate :validate_backend_id
  end

  scope :backend, where(:handler => "backend")

  def backend?
    self.handler == "backend"
  end

  private

  def validate_backend_id
    return if self.backend_id.blank? # handled by presence validation
    unless Backend.find_by_backend_id(self.backend_id)
      errors[:backend_id] << "does not exist"
    end
  end
end
