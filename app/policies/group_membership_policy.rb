class GroupMembershipPolicy < ApplicationPolicy
  
  def permitted_attributes
    [:user_id, :group_id]
  end

end