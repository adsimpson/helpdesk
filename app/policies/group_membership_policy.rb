class GroupMembershipPolicy < ApplicationPolicy
  
  def set_default?
    update?
  end
  
  def permitted_attributes
    [:user_id, :group_id]
  end

end