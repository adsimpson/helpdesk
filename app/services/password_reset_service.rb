class PasswordResetService
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
    token = unencrypted_token ? PasswordResetToken.find_by(token_digest: PasswordResetToken.encrypt(unencrypted_token)) : nil
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
    if email_address.nil?
      # TODO - should we send warning email to specified email address if no associated user account?
    else
      # delete any existing tokens for the email_address
      PasswordResetToken.where(email_address: email_address).delete_all
      
      # create a new token
      expires_at = token_expiration_window.hours.from_now
      @token = PasswordResetToken.create(email_address: email_address, expires_at: expires_at)
      
      # send email
      send_instructions_email
      
      # return token
      token
    end
  end
  
  def reset(password, password_confirmation)
    return false unless can_reset?
    # TODO - should we prevent user from setting the same password as previous?
    
    updated = user.update_attributes(   
        password: password, 
        password_confirmation: password_confirmation
    )
    if updated
      token.destroy
      send_success_email
    end
    updated
  end
  
  def can_reset?
    !!email_address && !!token && !token.expired?
  end
  
  # number of hours after which token will expire
  def token_expiration_window
    # TODO - configurable per tenant
    2
  end
  
 private
  
  def send_instructions_email
    UserMailer.password_reset_instructions(email_address, token, instructions_email_config).deliver
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
    UserMailer.password_reset_success(email_address, success_email_config).deliver
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
  
    
end