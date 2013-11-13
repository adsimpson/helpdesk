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
    return false if user.nil?
    generate_token
    user.verification_token_expires_at = token_expiration_window.hours.from_now
    user.save!
    send_instructions_email
  end
  
  def update(password, password_confirmation)
    return false unless can_update?
    # TODO - should we prevent user from setting the same password as previous?
    
    updated = user.update_attributes(   
        password: password, 
        password_confirmation: password_confirmation,
        verified: true,
        verification_token: nil, 
        verification_token_expires_at: nil
    )
    send_success_email if updated
    updated
  end

  def can_update?
    !!user && token_exists? && !token_expired?
  end
  
  def token_exists?
    !!user.verification_token
  end
  
  def token_expired?
    expires_at = user.verification_token_expires_at
    if expires_at.nil?
      return nil
    else
      expires_at < Time.now.utc
    end
  end

private
  
  def send_instructions_email
    # UserMailer.email_verification_instructions(user, instructions_email_config).deliver
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
    # UserMailer.email_verification_success(user, success_email_config).deliver
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