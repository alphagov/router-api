class Application
  include MongoMapper::Document

  key :application_id, String
  key :backend_url, String

  ensure_index :application_id, :unique => true

  validates :application_id, :presence => true, :uniqueness => true, :format => {:with => /\A[a-z0-9-]*\z/}
  validates :backend_url, :presence => true
end
