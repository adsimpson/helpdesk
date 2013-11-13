class GroupPolicy < ApplicationPolicy
  
  def permitted_attributes
    [:name]
  end

end
