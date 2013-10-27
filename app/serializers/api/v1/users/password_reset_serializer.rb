class  Api::V1::Users::PasswordResetSerializer < Api::V1::BaseSerializer
  
  # Set root node to 'passwordReset'
  configure :root, :instance => :passwordReset
  
  # Attributes
  attributes :token, :expires_at

  def token
    object.password_reset_token
  end
  
  def expires_at
    object.password_reset_token_expires_at
  end

end