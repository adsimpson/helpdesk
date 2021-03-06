class Api::V1::OrganizationSerializer < Api::V1::BaseSerializer
  serializes :Organization
  
   # Attributes
  attributes :id, :name, :notes, :external_id, :domains, :tags, :created_at, :updated_at
  
  def domains
    object.domains.pluck("name")
  end
  
  def tags
    object.tag_list
  end

  # Collection - Sorting
  sort_attributes :id, :name, :external_id, :created_at, :updated_at
  
  # Collection - Search
  search_attributes :id, :name, :external_id
  query_attributes :name
end
