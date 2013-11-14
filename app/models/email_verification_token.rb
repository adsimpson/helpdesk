class EmailVerificationToken < ActiveRecord::Base
  
  # readonly attribute - only set on create
  # this attribute is NOT persisted to the database
  # the +token_digest+ attribute is persisted
  attr_reader :token
  
  # associations
  belongs_to :user
 
  # callbacks
  before_create :generate_token 

  # instance methods
  
  # returns true if the expires_at timestamp has passed (if set), else false
  def expired?
    if self.expires_at.nil?
      return false
    else
      self.expires_at < Time.now.utc 
    end
  end

  # class methods
  
  def self.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  
  private
  
  # Encrypts the token into the +token_digest+ attribute, only if the
  # token is not blank.
  def token=(unencrypted_token)
    unless unencrypted_token.blank?
      @token = unencrypted_token
      self.token_digest = EmailVerificationToken.encrypt(token)
    end
  end
  
  # creates a unique token
  def generate_token
    begin
      self.token = SecureRandom.urlsafe_base64
    end while EmailVerificationToken.exists?(token_digest: token_digest)
  end
  
end