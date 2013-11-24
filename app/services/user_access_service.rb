class UserAccessService
  attr_reader :email_address, :token
  
  def self.from_email(email)
    email_address = EmailAddress.find_by(:value => email.downcase)
    new(email_address)
  end
  
  def self.from_token(unencrypted_token)
    token = unencrypted_token ? AccessToken.find_by(token_digest: AccessToken.encrypt(unencrypted_token)) : nil
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
  
  def authenticate(password)
    user && user.authenticate(password)
  end
  
  def suspended?
    user && user.active == false
  end
  
  def verified?
    email_address && email_address.verified
  end
  
  def signed_in?
    !!user
  end
  
  def sign_in
    return false if email_address.nil?
    
    # update user record with sign_in timestamp & increment sign_in_count
    old_latest, new_latest = user.latest_sign_in_at, Time.now.utc
    user.previous_sign_in_at = old_latest || new_latest
    user.latest_sign_in_at = new_latest
    
    user.sign_in_count ||= 0
    user.sign_in_count += 1
    user.save
    
    # delete current access_token if user already signed in
    # TODO - or should we just prevent the user from signing in?
    token.destroy unless token.nil?
    
    # create a new access token for the email address
    @token = AccessToken.create(email_address: email_address)
  end
  
  def sign_out
    # delete current access token
    token.destroy unless token.nil?
  end
  

end