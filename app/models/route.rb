class Route
  include Mongoid::Document

  field :incoming_path, :type => String
  field :route_type, :type => String
  field :handler, :type => String
  field :backend_id, :type => String
  field :redirect_to, :type => String
  field :redirect_type, :type => String

  index({:incoming_path => 1}, :unique => true)

  HANDLERS = %w(backend redirect gone)

  validates :incoming_path, :uniqueness => true
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

  after_create :cleanup_child_gone_routes

  scope :excluding, lambda {|route| where(:id => {:$ne => route.id}) }
  scope :prefix, lambda { where(:route_type => "prefix") }

  HANDLERS.each do |handler|
    scope handler, lambda { where(:handler => handler) }

    define_method "#{handler}?" do
      self.handler == handler
    end
  end

  def as_json(options = nil)
    super.tap do |h|
      h.delete("_id")
      h.delete_if {|k,v| v.nil? }
      h["errors"] = self.errors.as_json if self.errors.any?
    end
  end

  def soft_delete
    if self.has_parent_prefix_routes?
      destroy
    else
      update_attributes(:handler => "gone", :backend_id => nil, :redirect_to => nil, :redirect_type => nil)
    end
  end

  def has_parent_prefix_routes?
    segments = self.incoming_path.split('/').reject(&:blank?).tap(&:pop)
    while segments.any? do
      return true if Route.excluding(self).prefix.where(:incoming_path => "/#{segments.join('/')}").any?
      segments.pop
    end
    Route.excluding(self).prefix.where(:incoming_path => "/").any?
  end

  private

  def validate_incoming_path
    unless valid_local_path?(self.incoming_path)
      errors[:incoming_path] << "is not a valid absolute URL path"
    end
  end

  def validate_redirect_to
    return unless self.redirect_to.present? # This is to short circuit nil values
    if self.route_type == 'exact'
      unless valid_exact_redirect_target?(self.redirect_to)
        errors[:redirect_to] << "is not a valid redirect target"
      end
    else
      unless valid_local_path?(self.redirect_to)
        errors[:redirect_to] << "is not a valid redirect target"
      end
    end
  end

  def valid_local_path?(path)
    return false unless path.starts_with?("/")
    uri = URI.parse(path)
    uri.path == path && path !~ %r{//} && path !~ %r{./\z}
  rescue URI::InvalidURIError
    false
  end

  def valid_exact_redirect_target?(target)
    # Valid 'exact' redirect targets differ from standard targets in that we
    # allow:
    # 1. External URLs, or
    # 2. Query strings
    uri = URI.parse(target)
    return false unless (uri.absolute? || uri.path.starts_with?("/"))
    uri.absolute? || (uri.path !~ %r{//} && target !~ %r{./\z})
  rescue URI::InvalidURIError
    false
  end

  def validate_backend_id
    return if self.backend_id.blank? # handled by presence validation
    unless Backend.where(:backend_id => self.backend_id).first
      errors[:backend_id] << "does not exist"
    end
  end

  def cleanup_child_gone_routes
    return unless self.route_type == "prefix"
    Route.excluding(self).gone.where(:incoming_path => %r{\A#{Regexp.escape(self.incoming_path)}/}).destroy_all
  end
end
