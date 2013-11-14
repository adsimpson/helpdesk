class EmailVerificationService
  attr_reader :user, :token
  
  def self.active?
    # TODO - configurable per tenant
    true
  end
  
  def self.from_email(email)
    user = User.find_by(:email => email.downcase)
    new(user)
  end

  def self.from_token(unencrypted_token)
    token = unencrypted_token ? EmailVerificationToken.find_by(token_digest: EmailVerificationToken.encrypt(unencrypted_token)) : nil
    user = token && !token.expired? ? token.user : nil
    new(user, token)
  end
  
  def initialize(user, token=nil)
    @user = user
    @token = token
  end

  def send_instructions
    return false if user.nil?
    
    # delete any existing tokens for the user
    EmailVerificationToken.where(user: user).delete_all
    
    # create a new token
    expires_at = token_expiration_window.hours.from_now
    @token = EmailVerificationToken.create(user: user, expires_at: expires_at)
    
    # send email    
    send_instructions_email
    
    # return token
    token
  end
  
  def verify(password, password_confirmation)
    return false unless can_verify?
    # TODO - should we prevent user from setting the same password as previous?
    
    updated = user.update_attributes(   
        password: password, 
        password_confirmation: password_confirmation,
        verified: true
    )
    if updated
      token.destroy
      send_success_email
    end
    updated
  end

  def can_verify?
    !!user && !!token && !token.expired?
  end
  
private
  
  def send_instructions_email
    UserMailer.email_verification_instructions(user, token, instructions_email_config).deliver
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
    UserMailer.email_verification_success(user, success_email_config).deliver
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