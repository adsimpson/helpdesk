class UserAuthenticationService
  
  attr_reader :user, :access_token
  
  def self.from_email(email)
    user = User.find_by(:email => email.downcase)
    new(user)
  end
  
  def self.from_token(unencrypted_token)
    access_token = unencrypted_token ? AccessToken.find_by(token_digest: AccessToken.encrypt(unencrypted_token)) : nil
    user = access_token && !access_token.expired? ? access_token.user : nil
    new(user, access_token)
  end
  
  def initialize(user, access_token=nil)
    @user = user
    @access_token = access_token
  end
  
  def authenticate(password)
    user && user.authenticate(password)
  end
  
  def signed_in?
    !!user
  end
  
  def sign_in
    return false if user.nil?
    
    # update user record with sign_in timestamp & increment sign_in_count
    old_latest, new_latest = user.latest_sign_in_at, Time.now.utc
    user.previous_sign_in_at = old_latest || new_latest
    user.latest_sign_in_at = new_latest
    
    user.sign_in_count ||= 0
    user.sign_in_count += 1
    user.save
    
    # delete current access_token if user already signed in
    # TODO - or should we just prevent the user from signing in?
    access_token.destroy unless access_token.nil?
    
    # create a new access_token for the user
    @access_token = AccessToken.create(user: user)
  end
  
  def sign_out
    # delete current access_token
    access_token.destroy unless access_token.nil?
  end
  

end