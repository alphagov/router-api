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

  HANDLERS = %w[backend redirect gone].freeze

  DUPLICATE_KEY_ERROR = "E11000".freeze

  validates :incoming_path, uniqueness: true
  validate :validate_incoming_path
  validates :route_type, inclusion: { in: %w[prefix exact] }
  validates :handler, inclusion: { in: HANDLERS }
  with_options if: :backend? do
    validates :backend_id, presence: true
    validate :validate_backend_id
  end

  with_options if: :redirect? do
    validates :redirect_to, presence: true
    validate :validate_redirect_to
    validates :redirect_type, inclusion: { in: %w[permanent temporary] }
    validates :segments_mode, inclusion: { in: %w[ignore preserve] }
  end

  before_validation :default_segments_mode
  after_create :cleanup_child_gone_routes

  scope :excluding, ->(route) { where(id: { :$ne => route.id }) }
  scope :prefix, -> { where(route_type: "prefix") }

  HANDLERS.each do |handler|
    scope handler, -> { where(handler: handler) }

    define_method "#{handler}?" do
      self.handler == handler
    end
  end

  def as_json(options = {})
    options[:except] ||= %i[_id created_at updated_at]
    super(options).tap do |h|
      h.delete_if { |_k, v| v.nil? }
      h["errors"] = errors.as_json if errors.any?
    end
  end

  def soft_delete
    if has_parent_prefix_routes?
      destroy!
    else
      update!(handler: "gone", backend_id: nil, redirect_to: nil, redirect_type: nil)
    end
  end

  def has_parent_prefix_routes?
    segments = incoming_path.split("/").reject(&:blank?).tap(&:pop)
    while segments.any?
      return true if Route.excluding(self).prefix.where(incoming_path: "/#{segments.join('/')}").any?

      segments.pop
    end
    Route.excluding(self).prefix.where(incoming_path: "/").any?
  end

  def default_segments_mode
    return unless redirect?

    self.segments_mode ||= route_type == "prefix" ? "preserve" : "ignore"
  end

private

  def validate_incoming_path
    errors.add(:incoming_path, "must start with /") unless
      incoming_path.starts_with?("/")

    uri = URI.parse(incoming_path)

    errors.add(:incoming_path, "cannot end with /") if
      uri.path != "/" && uri.path.end_with?("/")
    errors.add(:incoming_path, "cannot contain //") if uri.path.match?(%r{//})

    errors.add(:incoming_path, "does not equal the URI path") unless
      uri.path == incoming_path
  rescue URI::InvalidURIError
    errors.add(:incoming_path, "is an invalid URI")
  end

  def validate_redirect_to
    return if redirect_to.blank? # This is to short circuit nil values

    uri = URI.parse(redirect_to)
    internal_uri = redirect_to.starts_with?(uri.path)

    if internal_uri
      errors.add(:redirect_to, "must start with a /") unless uri.path.starts_with?("/")
    else
      errors.add(:redirect_to, "must be an absolute URI") unless uri.absolute?
    end

    if segments_mode == "preserve"
      if uri.fragment.present?
        errors.add(:redirect_to, "cannot contain fragment if the segments mode is preserve")
      end

      if uri.query.present?
        errors.add(:redirect_to, "cannot contain query parameters if the segments mode is preserve")
      end
    end
  rescue URI::InvalidURIError
    errors.add(:redirect_to, "is an invalid URI")
  end

  def validate_backend_id
    return if backend_id.blank? # handled by presence validation

    unless Backend.where(backend_id: backend_id).exists?
      errors.add(:backend_id, "does not exist")
    end
  end

  def cleanup_child_gone_routes
    return unless route_type == "prefix"

    Route.excluding(self).gone.where(incoming_path: %r{\A#{::Regexp.escape(incoming_path)}/}).destroy_all
  end
end
