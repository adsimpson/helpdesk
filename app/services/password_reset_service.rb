class PasswordResetService
  attr_reader :user
  
  def self.active?
    # TODO - configurable per tenant
    true
  end
  
  def self.from_email(email)
    new User.find_by(:email => email.downcase)
  end

  def self.from_token(token)
    new User.find_by(:password_reset_token => token)
  end
  
  def initialize(user)
    @user = user
  end
  
  def send_instructions
    if user.nil?
      # TODO - should we send warning email to specified email address if no associated user account?
    else
      generate_token
      user.password_reset_token_expires_at = token_expiration_window.hours.from_now
      user.save!
      send_instructions_email
    end
  end
  
  def reset(password, password_confirmation)
    return false unless can_reset?
    # TODO - should we prevent user from setting the same password as previous?
    
    updated = user.update_attributes(   
        password: password, 
        password_confirmation: password_confirmation,
        password_reset_token: nil, 
        password_reset_token_expires_at: nil
    )
    send_success_email if updated
    updated
  end
  
  def can_reset?
    !!user && token_exists? && !token_expired?
  end
  
  def token_exists?
    !!user.password_reset_token
  end
  
  def token_expired?
    expires_at = user.password_reset_token_expires_at
    if expires_at.nil?
      return false
    else
      expires_at < Time.now.utc
    end
  end

  # number of hours after which token will expire
  def token_expiration_window
    # TODO - configurable per tenant
    2
  end
  
 private
  
  def send_instructions_email
    UserMailer.password_reset_instructions(user, instructions_email_config).deliver
  end
  
  def instructions_email_config
    # TODO - configurable per tenant
    {
      :base_url => 'http://example.com/passwordReset',
      :message_format => 'HTML',
      :from_name => 'HelpDesk',
      :from_email => 'no_reply@helpdesk.com',
      :subject => 'HelpDesk Password Assistance',
      :body =>  '.....'
      }
  end
  
  def send_success_email
    UserMailer.password_reset_success(user, success_email_config).deliver
  end
  
  def success_email_config
    # TODO - configurable per tenant
    {
      :message_format => 'HTML',
      :from_name => 'HelpDesk',
      :from_email => 'no_reply@helpdesk.com',
      :subject => 'Your password has been changed',
      :body =>  '.....'
      }
  end
  
  def generate_token
    begin
      user.password_reset_token = SecureRandom.hex
    end while User.exists?(password_reset_token: user.password_reset_token)
  end
    
end