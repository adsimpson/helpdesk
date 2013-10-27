class Api::V1::Users::AuthenticationSerializer < Api::V1::BaseSerializer
  
  # Set root node to 'authentication'
  configure :root, :instance => :authentication
  
  # Attributes
  attributes :token

  def token
    object.access_token
  end
  
end