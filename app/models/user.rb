class User < ActiveRecord::Base
  
  belongs_to :organization
  has_many :group_memberships, :dependent => :destroy
  has_many :groups, :through => :group_memberships
  
  before_validation :generate_random_password, :on => :create
  before_save { self.email = email.downcase }
  after_save :delete_group_memberships!
  
  validates :name, presence: true, length: {maximum: 50}
  validates_inclusion_of :role, :in => ["admin", "agent", "end_user"]
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  
  has_secure_password
  MIN_PASSWORD_LENGTH = 6
  validates :password, length: { minimum: MIN_PASSWORD_LENGTH }, allow_nil: true

  validate :validate_linked_organization
  
  # CLASS METHODS
  
  # generates a random password consisting of strings and digits
  def self.random_password
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a 
    password = ""
    1.upto(MIN_PASSWORD_LENGTH) { |i| password << chars[rand(chars.size-1)]}
    return password
  end
  
  # INSTANCE METHODS
  
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
  
  # if role changed to end_user - delete all group memberships for user
  def delete_group_memberships!
    GroupMembership.where(user: self).delete_all if self.end_user?
  end
  
  # validation - ensure organization can only be linked if :role = 'agent' or 'end_user' & that it is valid
  def validate_linked_organization
    unless self.organization_id.nil?
      errors.add(:organization, "can't be found") unless self.organization.present?
      errors.add(:organization, "can't be linked unless role is 'agent' or 'end_user'") unless (self.agent? || self.end_user?)
    end
  end
  
  # on create - generate random password if both password & password_confirmation are nil
  def generate_random_password
    if self.password.nil? && self.password_confirmation.nil?
      self.password = self.password_confirmation = User.random_password
    end
  end
  
end
