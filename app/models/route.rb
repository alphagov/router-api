class Route
  include Mongoid::Document
  include Mongoid::Timestamps

  field :incoming_path, type: String
  field :route_type, type: String
  field :handler, type: String
  field :disabled, type: Boolean, default: false
  field :backend_id, type: String
  field :redirect_to, type: String
  field :redirect_type, type: String
  field :segments_mode, type: String

  index({ incoming_path: 1 }, unique: true)

  # The router loads the routes in order, and therefore needs this index.
  # This is to enable it to generate a consistent checksum of the routes.
  index(incoming_path: 1, route_type: 1)

  HANDLERS = %w(backend redirect gone).freeze

  DUPLICATE_KEY_ERROR = "E11000".freeze

  validates :incoming_path, uniqueness: true
  validate :validate_incoming_path
  validates :route_type, inclusion: { in: %w(prefix exact) }
  validates :handler, inclusion: { in: HANDLERS }
  with_options if: :backend? do |be|
    be.validates :backend_id, presence: true
    be.validate :validate_backend_id
  end

  with_options if: :redirect? do |be|
    be.validates :redirect_to, presence: true
    be.validate :validate_redirect_to
    be.validates :redirect_type, inclusion: { in: %w(permanent temporary) }
    be.validates :segments_mode, inclusion: { in: %w(ignore preserve) }
  end

  before_validation :default_segments_mode
  after_create :cleanup_child_gone_routes

  scope :excluding, lambda { |route| where(id: { :$ne => route.id }) }
  scope :prefix, lambda { where(route_type: "prefix") }

  HANDLERS.each do |handler|
    scope handler, lambda { where(handler: handler) }

    define_method "#{handler}?" do
      self.handler == handler
    end
  end

  def as_json(options = {})
    options[:except] ||= %i[_id created_at updated_at]
    super(options).tap do |h|
      h.delete_if { |_k, v| v.nil? }
      h["errors"] = self.errors.as_json if self.errors.any?
    end
  end

  def soft_delete
    if self.has_parent_prefix_routes?
      destroy
    else
      update(handler: "gone", backend_id: nil, redirect_to: nil, redirect_type: nil)
    end
  end

  def has_parent_prefix_routes?
    segments = self.incoming_path.split("/").reject(&:blank?).tap(&:pop)
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
    errors[:incoming_path] << "must start with /" unless
      incoming_path.starts_with?("/")

    uri = URI.parse(incoming_path)

    errors[:incoming_path] << "cannot end with /" if
      uri.path != "/" && uri.path.end_with?("/")
    errors[:incoming_path] << "cannot contain //" if uri.path.match?(%r{//})

    errors[:incoming_path] << "does not equal the URI path" unless
      uri.path == incoming_path
  rescue URI::InvalidURIError
    errors[:incoming_path] << "is an invalid URI"
  end

  def validate_redirect_to
    return unless self.redirect_to.present? # This is to short circuit nil values

    if self.redirect_to.starts_with?("/")
      validate_internal_target(self.redirect_to)
    else
      validate_external_target(self.redirect_to)
    end

    if segments_mode == "preserve"
      uri = URI.parse(redirect_to)

      if uri.fragment.present?
        errors[:redirect_to] << "cannot contain fragment if the segments mode is preserve"
      end

      if uri.query.present?
        errors[:redirect_to] << "cannot contain query parameters if the segments mode is preserve"
      end
    end
  rescue URI::InvalidURIError
    errors[:redirect_to] << "is an invalid URI"
  end

  def validate_external_target(target)
    uri = URI.parse(target)
    errors[:redirect_to] << "must be an absolute URI" unless uri.absolute?

    return unless errors[:redirect_to].empty? # Don't continue, as the host validation may fail

    errors[:redirect_to] << "external domain must be within .gov.uk or british-business-bank.co.uk" unless
      uri.host.end_with?(".gov.uk") || uri.host == "british-business-bank.co.uk"
  rescue URI::InvalidURIError
    errors[:redirect_to] << "is an invalid URI"
  end

  def validate_internal_target(target)
    uri = URI.parse(target)
    errors[:redirect_to] << "uri path cannot contain //" if uri.path.match?(%r{//})
    errors[:redirect_to] << "cannot end with /" if target.match?(%r{./\z})
  rescue URI::InvalidURIError
    errors[:redirect_to] << "is an invalid URI"
  end

  def validate_backend_id
    return if self.backend_id.blank? # handled by presence validation

    unless Backend.where(backend_id: self.backend_id).exists?
      errors[:backend_id] << "does not exist"
    end
  end

  def cleanup_child_gone_routes
    return unless self.route_type == "prefix"

    Route.excluding(self).gone.where(incoming_path: %r{\A#{::Regexp.escape(self.incoming_path)}/}).destroy_all
  end
end
