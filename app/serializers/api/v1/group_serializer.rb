class Api::V1::GroupSerializer < Api::V1::BaseSerializer
  serializes :Group
  
   # Attributes
  attributes :id, :name, :created_at, :updated_at
 
  # Collection - Sorting
  sort_attributes :id, :name, :created_at, :updated_at
  
  # Collection - Search
  search_attributes :id, :name
  query_attributes :name
end
