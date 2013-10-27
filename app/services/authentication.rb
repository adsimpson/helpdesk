class Authentication
  
  attr_reader :user
  
  def self.from_email(email)
    new User.find_by(:email => email.downcase)
  end
  
  def self.from_token(token)
    new token ? User.find_by(access_token: token) : nil
  end
  
  def initialize(user)
    @user = user
  end
  
  def check_password(password)
    user && user.authenticate(password)
  end
  
  def account_active?
    user && user.active
  end
  
  def account_verified?
    user && user.verified
  end
  
  def signed_in?
    !!user
  end
  
  def sign_in
    return false if user.nil?
    # TODO - should we prevent sign-in if user already signed-in?
    
    old_latest, new_latest = user.latest_sign_in_at, Time.now.utc
    user.previous_sign_in_at = old_latest # || new_latest
    user.latest_sign_in_at = new_latest
    
    user.sign_in_count ||= 0
    user.sign_in_count += 1
    generate_token
    user.save
  end
  
  def sign_out
    return false if user.nil?
    generate_token
    user.save
  end
  
private
  
    def generate_token
      begin
        user.access_token = SecureRandom.urlsafe_base64
      end while User.exists?(access_token: user.access_token)
    end

end