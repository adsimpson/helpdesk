class Api::V1::TagSerializer < Api::V1::BaseSerializer
  serializes "ActsAsTaggableOn::Tag"
  
  # Don't provide meta data
  configure :meta,  :active => false
  
   # Attributes
  def serialize_collection
    object.pluck(:name)
  end
  
end