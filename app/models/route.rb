class Route
  include MongoMapper::Document

  key :incoming_path, String
  key :route_type, String
  key :handler, String
  key :backend_id, String
  key :redirect_to, String
  key :redirect_type, String

  ensure_index [[:incoming_path, 1], [:route_type, 1]], :unique => true

  HANDLERS = %w(backend redirect gone)

  validates :incoming_path, :uniqueness => {:scope => :route_type}
  validate :validate_incoming_path
  validates :route_type, :inclusion => {:in => %w(prefix exact)}
  validates :handler, :inclusion => {:in => HANDLERS}
  with_options :if => :backend? do |be|
    be.validates :backend_id, :presence => true
    be.validate :validate_backend_id
  end

  with_options :if => :redirect? do |be|
    be.validates :redirect_to, :presence => true
    be.validate :validate_redirect_to
    be.validates :redirect_type, :inclusion => {:in => %w(permanent temporary)}
  end

  scope :excluding, lambda {|route| where(:id => {:$ne => route.id}) }
  scope :prefix, where(:route_type => "prefix")

  HANDLERS.each do |handler|
    scope handler, where(:handler => handler)

    define_method "#{handler}?" do
      self.handler == handler
    end
  end

  def as_json(options = nil)
    super.tap do |h|
      h.delete("id")
      h["errors"] = self.errors.as_json if self.errors.any?
    end
  end

  def soft_delete
    if self.has_parent_prefix_routes?
      destroy
    else
      update_attributes(:handler => "gone", :backend_id => nil)
    end
  end

  def has_parent_prefix_routes?
    segments = self.incoming_path.split('/').reject(&:blank?)
    while segments.any? do
      return true if Route.excluding(self).prefix.where(:incoming_path => "/#{segments.join('/')}").any?
      segments.pop
    end
    Route.prefix.where(:incoming_path => "/").any?
  end

  private

  def validate_incoming_path
    unless valid_local_path?(self.incoming_path)
      errors[:incoming_path] << "is not a valid absolute URL path"
    end
  end

  def validate_redirect_to
    return unless self.redirect_to.present? # This is to short circuit nil values
    unless valid_local_path?(self.redirect_to)
      errors[:redirect_to] << "is not a valid absolute URL path"
    end
  end

  def valid_local_path?(path)
    return false unless path.starts_with?("/")
    uri = URI.parse(path)
    uri.path == path && path !~ %r{//} && path !~ %r{./\z}
  rescue URI::InvalidURIError
    false
  end

  def validate_backend_id
    return if self.backend_id.blank? # handled by presence validation
    unless Backend.find_by_backend_id(self.backend_id)
      errors[:backend_id] << "does not exist"
    end
  end
end
