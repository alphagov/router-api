class User
  include GDS::SSO::User
  include Mongoid::Document

  field :name, type: String
  field :email, type: String
  field :uid, type: String
  field :organisation_slug, type: String
  field :organisation_content_id, type: String
  field :permissions, type: Array
  field :remotely_signed_out, type: Boolean, default: false
  field :disabled, type: Boolean, default: false
end
