class Api::V1::AccessTokenSerializer < Api::V1::BaseSerializer
  serializes :AccessToken  
  
  # Set root node to 'access'
  configure :root, :instance => :access
  
  # Attributes
  attributes :token
  
end