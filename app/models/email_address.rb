class EmailAddress < ActiveRecord::Base
  
  # associations
  belongs_to :user

  # validations
  validates_existence_of :user, allow_nil: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :value, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  # callbacks
  before_save :set_as_primary, on: :create
  before_save :update_value_lower
  after_save :ensure_only_one_primary
  after_save :delete_email_verification_tokens
  before_destroy :ensure_primary_cannot_be_deleted

private
  
  def update_value_lower
    self.value = value.downcase
  end
  
  # set as user's primary email address if they don't have any existing email addresses
  def set_as_primary
    self.primary = true if (self.user && self.user.email_addresses.count == 0)
  end
  
  def ensure_only_one_primary
    if self.primary 
      other_email_addresses = self.user.email_addresses.where.not(id: self.id)
      other_email_addresses.update_all(primary: false)
    end
  end
  
  def ensure_primary_cannot_be_deleted
    if self.primary     
      self.errors[:base] << "Cannot delete user's primary email address"
      return false   
    end 
  end
  
  def delete_email_verification_tokens
    if self.verified && self.verified_changed?
      EmailVerificationToken.where(email_address: self).delete_all
    end
  end
    
end
