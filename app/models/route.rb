class Route
  include Mongoid::Document

  field :incoming_path, type: String
  field :route_type, type: String
  field :handler, type: String
  field :disabled, type: Boolean, default: false
  field :backend_id, type: String
  field :redirect_to, type: String
  field :redirect_type, type: String
  field :segments_mode, type: String

  index({incoming_path: 1}, unique: true)

  # The router loads the routes in order, and therefore needs this index.
  # This is to enable it to generate a consistent checksum of the routes.
  index({incoming_path: 1, route_type: 1})

  HANDLERS = %w(backend redirect gone)

  DUPLICATE_KEY_ERROR = 11000

  validates :incoming_path, uniqueness: true
  validate :validate_incoming_path
  validates :route_type, inclusion: {in: %w(prefix exact)}
  validates :handler, inclusion: {in: HANDLERS}
  with_options if: :backend? do |be|
    be.validates :backend_id, presence: true
    be.validate :validate_backend_id
  end

  with_options if: :redirect? do |be|
    be.validates :redirect_to, presence: true
    be.validate :validate_redirect_to
    be.validates :redirect_type, inclusion: {in: %w(permanent temporary)}
    be.validates :segments_mode, inclusion: {in: %w(ignore preserve)}
  end

  before_validation :default_segments_mode
  after_create :cleanup_child_gone_routes

  scope :excluding, lambda {|route| where(id: {:$ne => route.id}) }
  scope :prefix, lambda { where(route_type: "prefix") }

  HANDLERS.each do |handler|
    scope handler, lambda { where(handler: handler) }

    define_method "#{handler}?" do
      self.handler == handler
    end
  end

  def as_json(options = nil)
    super.tap do |h|
      h.delete("_id")
      h.delete_if {|_k, v| v.nil? }
      h["errors"] = self.errors.as_json if self.errors.any?
    end
  end

  def soft_delete
    if self.has_parent_prefix_routes?
      destroy
    else
      update_attributes(handler: "gone", backend_id: nil, redirect_to: nil, redirect_type: nil)
    end
  end

  def has_parent_prefix_routes?
    segments = self.incoming_path.split('/').reject(&:blank?).tap(&:pop)
    while segments.any? do
      return true if Route.excluding(self).prefix.where(incoming_path: "/#{segments.join('/')}").any?
      segments.pop
    end
    Route.excluding(self).prefix.where(incoming_path: "/").any?
  end

  def default_segments_mode
    return unless redirect?
    self.segments_mode ||= self.route_type == "prefix" ? "preserve" : "ignore"
  end

  private

  def validate_incoming_path
    unless self.incoming_path.starts_with?("/") &&
        valid_local_path?(self.incoming_path)
      errors[:incoming_path] << "is not a valid absolute URL path"
    end
  end

  def validate_redirect_to
    return unless self.redirect_to.present? # This is to short circuit nil values

    if self.redirect_to.starts_with?("/")
      unless valid_local_path?(self.redirect_to)
        errors[:redirect_to] << "is not a valid internal redirect target"
      end
    else
      unless valid_external_target?(self.redirect_to)
        errors[:redirect_to] << "is not a valid external redirect target"
      end
    end
  end

  def valid_external_target?(target)
    uri = URI.parse(target)
    uri.absolute? && uri.host.end_with?(".gov.uk")
  rescue URI::InvalidURIError
    false
  end

  def valid_local_path?(target)
    uri = URI.parse(target)
    uri.path == target && uri.path !~ %r{//} && target !~ %r{./\z}
  rescue URI::InvalidURIError
    false
  end

  def validate_backend_id
    return if self.backend_id.blank? # handled by presence validation
    unless Backend.where(backend_id: self.backend_id).exists?
      errors[:backend_id] << "does not exist"
    end
  end

  def cleanup_child_gone_routes
    return unless self.route_type == "prefix"
    Route.excluding(self).gone.where(incoming_path: %r{\A#{Regexp.escape(self.incoming_path)}/}).destroy_all
  end
end
