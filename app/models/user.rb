class User < ActiveRecord::Base
  
  # associations
  belongs_to :organization
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  
  # validations
  validates :name, presence: true, length: {maximum: 50}
  validates_inclusion_of :role, in: ["admin", "agent", "end_user"]
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  
  has_secure_password
  MIN_PASSWORD_LENGTH = 6
  validates :password, length: { minimum: MIN_PASSWORD_LENGTH }, allow_nil: true
  
  validates_existence_of :organization, allow_nil: true
  validate :organization_validator

  # callbacks
  before_validation :ensure_password_is_present, on: :create 
  before_save :update_email_lower
  before_save :map_organization_from_domain
  after_save :delete_group_memberships_for_end_users
  
  # class methods
  
  # generates a random password consisting of strings and digits
  def self.random_password
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a 
    password = ""
    1.upto(MIN_PASSWORD_LENGTH) { |i| password << chars[rand(chars.size-1)]}
    return password
  end
  
  # instance methods
  
  def role?(role)
    self.role == role
  end
  
  def admin?
    self.role == "admin"
  end

  def agent?
    self.role == "agent"
  end
  
  def admin_or_agent?
    self.admin? || self.agent?
  end

  def end_user?
    self.role == "end_user"
  end
  
private
  
  def ensure_password_is_present
    if (self.password.nil? && self.password_confirmation.nil?)
      self.password = self.password_confirmation = User.random_password
    end
  end
  
  def update_email_lower
    self.email = email.downcase
  end
  
  def map_organization_from_domain
    if (self.end_user? && self.organization.nil?)
      domain_name = self.email.split("@")[1]
      domain = Domain.where(name: domain_name).first
      self.organization = domain.organization if (domain && domain.organization)
    end
  end
  
  # if role changed to end_user - delete all group memberships for user
  def delete_group_memberships_for_end_users
    GroupMembership.where(user: self).delete_all if self.end_user?
  end
    
  def organization_validator
    unless (self.organization.nil? || self.agent? || self.end_user? )
      errors.add(:organization, "can't be assigned unless role is 'agent' or 'end_user'") 
    end
  end
  
end
