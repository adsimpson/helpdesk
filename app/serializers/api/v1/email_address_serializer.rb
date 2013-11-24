class Api::V1::EmailAddressSerializer < Api::V1::BaseSerializer
  serializes :EmailAddress
  
   # Attributes
  attributes :id, :user_id, :value, :primary, :verified, :created_at, :updated_at
  
  # Collection - Sorting
  sort_attributes :id, :user_id, :value, :primary, :verified, :created_at, :updated_at
  
  # Collection - Search
  search_attributes :id, :value, :primary, :verified
  query_attributes :value
end