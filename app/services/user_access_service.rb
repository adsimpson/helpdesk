class UserAccessService
  attr_reader :user, :token
  
  def self.from_email(email)
    user = User.find_by(:email => email.downcase)
    new(user)
  end
  
  def self.from_token(unencrypted_token)
    token = unencrypted_token ? AccessToken.find_by(token_digest: AccessToken.encrypt(unencrypted_token)) : nil
    user = token && !token.expired? ? token.user : nil
    new(user, token)
  end
  
  def initialize(user, token=nil)
    @user = user
    @token = token
  end
  
  def authenticate(password)
    user && user.authenticate(password)
  end
  
  def suspended?
    user && user.active == false
  end
  
  def verified?
    user && user.verified
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
    token.destroy unless token.nil?
    
    # create a new access token for the user
    @token = AccessToken.create(user: user)
  end
  
  def sign_out
    # delete current access token
    token.destroy unless token.nil?
  end
  

end