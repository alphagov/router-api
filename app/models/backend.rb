class Backend
  include MongoMapper::Document

  key :backend_id, String
  key :backend_url, String

  ensure_index :backend_id, :unique => true

  validates :backend_id, :presence => true, :uniqueness => true, :format => {:with => /\A[a-z0-9-]*\z/}
  validates :backend_url, :presence => true
end
