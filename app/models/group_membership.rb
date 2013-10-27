class GroupMembership < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :group

  validates_presence_of :user, :group
  validates_associated :user, :group
  
  before_validation :set_as_user_default, :on => :create
  
private

  # on create - set as user's default group membership if they are not members of any other group
  def set_as_user_default
    self.default = true if (self.user && self.user.groups.count == 0)
  end

end