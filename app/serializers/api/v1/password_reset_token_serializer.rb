class  Api::V1::PasswordResetTokenSerializer < Api::V1::BaseSerializer
  serializes :PasswordResetToken
  
  # Set root node to 'password_reset'
  configure :root, :instance => :password_reset
  
  # Attributes
  attributes :expires_at
  
end