class  Api::V1::Users::EmailVerificationSerializer < Api::V1::BaseSerializer
  
  # Set root node to 'emailVerification'
  configure :root, :instance => :emailVerification
  
  # Attributes
  attributes :token, :expires_at
  
  def token
    object.verification_token
  end
  
  def expires_at
    object.verification_token_expires_at
  end

end