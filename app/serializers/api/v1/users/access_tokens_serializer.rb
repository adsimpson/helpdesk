class Api::V1::Users::AccessTokenSerializer < Api::V1::BaseSerializer
  
  # Set root node to 'api_key'
  configure :root, :instance => :access
  
  # Attributes
  attributes :token
  
end