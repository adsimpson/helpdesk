class Api::V1::UserSerializer < Api::V1::BaseSerializer
  serializes :User
  
  # Links
  link :self do
    #url_for([:api, object])
    api_user_path(object)
  end
  
  link :groupMemberships do
   "#{api_user_path(object)}/groupMemberships"
  end

  # Attributes
attributes :id, :name, :email, :role, :active, :verified, :status, :created_at, :updated_at
 
  def filter(keys)
    if scope.nil?
      keys   #- [:active, :verified, :status]
    else
      keys 
    end
  end

  # Decorator attributes
  def status
    !object.active ? 'suspended' : !object.verified ? 'unverified' : 'active'
  end
 
  # Collection - Sorting
  sort_attributes :id, :name, :email, :role, :created_at, :updated_at
  
  # Collection - Search
  search_attributes :id, :name, :email, :role, :active, :verified
  query_attributes :name, :email 
end