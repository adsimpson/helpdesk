class  Api::V1::EmailVerificationTokenSerializer < Api::V1::BaseSerializer
  serializes :EmailVerificationToken  
  
  # Set root node to 'email_verification'
  configure :root, :instance => :email_verification
  
  # Attributes
  attributes :expires_at
  
end