class Backend
  include MongoMapper::Document

  key :backend_id, String
  key :backend_url, String

  ensure_index :backend_id, :unique => true

  validates :backend_id, :presence => true, :uniqueness => true, :format => {:with => /\A[a-z0-9-]*\z/}
  validates :backend_url, :presence => true, :format => {:with => URI.regexp("http"), :allow_blank => true}

  before_destroy :ensure_no_linked_routes

  def as_json
    super.tap do |h|
      h.delete("id")
      h["errors"] = self.errors.as_json if self.errors.any?
    end
  end

  private

  def ensure_no_linked_routes
    if Route.backend.find_all_by_backend_id(self.backend_id).any?
      errors[:base] << "Backend has routes - can't delete"
      return false
    end
  end
end
