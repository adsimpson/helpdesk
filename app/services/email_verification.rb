class EmailVerification
  attr_reader :user
  
  def self.service_active?
    # TODO - configurable per tenant
    true
  end
  
  def self.from_email(email)
    new User.find_by(:email => email.downcase)
  end
  
  def self.from_token(token)
    new User.find_by(:verification_token => token)
  end
  
  def initialize(user)
    @user = user
  end

  def send_instructions
    unless user.nil?
      generate_token
      user.verification_token_expires_at = token_expiration_window.hours.from_now
      user.save!
      # UserMailer.email_verification_instructions(user, instructions_email_config).deliver
    end
  end
  
  def update(password, password_confirmation)
    return false if user.nil?
    # TODO - should we prevent user from setting the same password as previous?
    
    updated = user.update_attributes(   
        password: password, 
        password_confirmation: password_confirmation,
        verified: true,
        verification_token: nil, 
        verification_token_expires_at: nil
    )
    # UserMailer.email_verification_success(user, success_email_config).deliver if updated
    updated
  end

  def token_expired?
    user.verification_token_expires_at < Time.now.utc
  end

private
  
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
  
  def generate_token
    begin
      user.verification_token = SecureRandom.urlsafe_base64
    end while User.exists?(verification_token: user.verification_token)
  end  
    
end