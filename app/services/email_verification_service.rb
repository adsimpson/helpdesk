class EmailVerificationService
  attr_reader :email_address, :token
  
  def self.active?
    # TODO - configurable per tenant
    true
  end
  
  def self.from_email(email)
    email_address = EmailAddress.find_by(:value => email.downcase)
    new(email_address)
  end

  def self.from_token(unencrypted_token)
    token = unencrypted_token ? EmailVerificationToken.find_by(token_digest: EmailVerificationToken.encrypt(unencrypted_token)) : nil
    email_address = token && !token.expired? ? token.email_address : nil
    new(email_address, token)
  end
  
  def initialize(email_address, token=nil)
    @email_address = email_address
    @token = token
  end
  
  def user
    email_address.nil? ? nil : email_address.user
  end
  
  def send_instructions
    return false if email_address.nil?
    
    # delete any existing tokens for the email address
    EmailVerificationToken.where(email_address: email_address).delete_all
    
    # create a new token
    expires_at = token_expiration_window.hours.from_now
    @token = EmailVerificationToken.create(email_address: email_address, expires_at: expires_at)
    
    # send email    
    send_instructions_email
    
    # return token
    token
  end
  
  def verify(password, password_confirmation)
    return false unless can_verify?
    
    updated = user.update_attributes password: password, password_confirmation: password_confirmation
    if updated
      email_address.update_attributes(verified: true)
      # EmailAddress model deletes any associated tokens when verified updated to true
      send_success_email
    end
    updated
  end

  def can_verify?
    !!email_address && !!token && !token.expired?
  end
  
private
  
  def send_instructions_email
    UserMailer.email_verification_instructions(email_address, token, instructions_email_config).deliver
  end
  
  def instructions_email_config
    # TODO - configurable per tenant
    {
      :base_url => 'http://example.com/emailVerification',
      :message_format => 'HTML',
      :from_name => 'HelpDesk',
      :from_email => 'no_reply@helpdesk.com',
      :subject => 'HelpDesk Email Verification',
      :body =>  '.....'
      }
  end
  
  def send_success_email
    UserMailer.email_verification_success(email_address, success_email_config).deliver
  end
  
  def success_email_config
    # TODO - configurable per tenant
    {
      :message_format => 'HTML',
      :from_name => 'HelpDesk',
      :from_email => 'no_reply@helpdesk.com',
      :subject => 'Your email address has been verified',
      :body =>  '.....'
      }
  end
  
  # number of hours after which token will expire
  def token_expiration_window
    # TODO - configurable per tenant
    72
  end
    
end