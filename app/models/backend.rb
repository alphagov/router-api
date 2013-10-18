class Backend
  include MongoMapper::Document

  key :backend_id, String
  key :backend_url, String

  ensure_index :backend_id, :unique => true

  validates :backend_id, :presence => true, :uniqueness => true, :format => {:with => /\A[a-z0-9-]*\z/}
  validates :backend_url, :presence => true

  before_destroy :ensure_no_linked_routes

  def as_json
    super().reject {|k,v| k == "id"}
  end

  private

  def ensure_no_linked_routes
    if Route.backend.find_all_by_backend_id(self.backend_id).any?
      return false
    end
  end
end
