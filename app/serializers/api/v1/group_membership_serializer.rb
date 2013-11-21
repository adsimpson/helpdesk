class Api::V1::GroupMembershipSerializer < Api::V1::BaseSerializer
  serializes :GroupMembership
  
   # Attributes
  attributes :id, :group_id, :user_id, :default, :created_at, :updated_at
  
  # Collection - Sorting
  sort_attributes :id, :group_id, :user_id, :name, :created_at, :updated_at
  
  # Collection - Search
  search_attributes :id, :default
end