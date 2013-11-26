class User < ActiveRecord::Base
  
  # associations
  belongs_to :organization
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :email_addresses, dependent: :delete_all
  accepts_nested_attributes_for :email_addresses, allow_destroy: true
  acts_as_taggable
  
  # validations
  validates :name, presence: true, length: {maximum: 50}
  validates_inclusion_of :role, in: ["admin", "agent", "end_user"]
  validate :email_addresses_validator
  
  has_secure_password
  MIN_PASSWORD_LENGTH = 6
  validates :password, length: { minimum: MIN_PASSWORD_LENGTH }, allow_nil: true
  
  validates_existence_of :organization, allow_nil: true
  validate :organization_validator

  # callbacks
  before_validation :ensure_password_is_present, on: :create 
  after_save :map_organization_from_domain
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
    self.role == role.to_s
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
  
  def email
    primary_email_address.nil? ? nil : primary_email_address.value
  end
  
  def verified
    primary_email_address.nil? ? false : primary_email_address.verified
  end
  
  def primary_email_address
    self.email_addresses.where(primary: true).first
  end
  
private
  
  def ensure_password_is_present
    if (self.password.nil? && self.password_confirmation.nil?)
      self.password = self.password_confirmation = User.random_password
    end
  end
  
  def map_organization_from_domain
    if (self.end_user? && self.organization.nil?)
      domain_name = self.email.split("@")[1]
      domain = Domain.where(name: domain_name).first
      self.update_attributes(organization: domain.organization) if (domain && domain.organization)
    end
  end
  
  # if role changed to end_user - delete all group memberships for user
  def delete_group_memberships_for_end_users
    self.group_memberships.delete_all if self.end_user?
  end
    
  def organization_validator
    unless (self.organization.nil? || self.agent? || self.end_user? )
      errors.add(:organization, "can't be assigned unless role is 'agent' or 'end_user'") 
    end
  end
  
  def email_addresses_validator
    errors.add(:base, "User must have an email address") unless self.email_addresses.first
  end
  
end
