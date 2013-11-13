class GroupMembership < ActiveRecord::Base
  
  # associations
  belongs_to :user
  belongs_to :group
  
  # validations
  validates_existence_of :user, :group
  validate :user_validator
  
  # callbacks
  before_save :set_as_user_default, on: :create
  
private

  def user_validator
    # don't allow end_users to be included in groups
    errors.add(:user, "can't be included if role is 'end_user'") if (self.user && self.user.end_user?)
  end
  
  # set as user's default group membership if they are not members of any other group
  def set_as_user_default
    self.default = true if (self.user && self.user.groups.count == 0)
  end
  
end