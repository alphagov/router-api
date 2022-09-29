class Backend
  include Mongoid::Document
  include Mongoid::Timestamps

  field :backend_id, type: String
  field :backend_url, type: String

  index({ backend_id: 1 }, unique: true)

  validates :backend_id, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]*\z/ }
  validate :validate_backend_url

  before_destroy :ensure_no_linked_routes

  def as_json(options = {})
    options[:except] ||= %i[_id created_at updated_at]
    super(options).tap do |h|
      h["errors"] = errors.as_json if errors.any?
    end
  end

private

  def validate_backend_url
    errors.add(:backend_url, "is not a valid HTTP URL") unless valid_backend_url?
  end

  def valid_backend_url?
    uri = URI.parse(backend_url)
    uri.scheme =~ /^https?$/ &&
      uri.host.present? &&
      uri.path.present? &&
      uri.query.blank? &&
      uri.fragment.blank?
  rescue URI::InvalidURIError
    false
  end

  def ensure_no_linked_routes
    if Route.backend.where(backend_id:).any?
      errors.add(:base, "Backend has routes - can't delete")
      throw :abort
    end
  end
end
