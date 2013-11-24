class UserPolicy < ApplicationPolicy
  
  def show?
    # end_users can only view their own user record
    if user.end_user?
      is_current_user?
    # admins & agents can view all user records
    else
      true
    end
  end
  
  def show_current_user?
    show?
  end
  
  def create?
    default_permissions
  end
  
  def update?
    # all users can update themselves
    if is_current_user?
      true
    # else apply default permissions
    else
      default_permissions
    end
  end
  
  def destroy?
    # users cannot delete themselves
    if is_current_user?
      false
    # else apply default permissions
    else
      default_permissions
    end
  end
  
  def permitted_attributes
    attrs = [:name, :password, :password_confirmation]
    # email or emails is only permitted when creating a user
    attrs.concat([:email, :emails => []]) if record.new_record?
    # administrators can update user roles, but not for themselves
    # administrators & agents can update other users' organizations
    # users cannot update their own active & verified status
    unless is_current_user?
      attrs << :role if user.admin?
      attrs << :organization_id if user.admin? || user.agent?
      attrs << :active
      attrs << :verified
    end
    attrs
  end

private
  
  def default_permissions
    # admins can create/update/delete all user roles
    if user.admin?
      true
    # agents can only create/update/delete end_users
    elsif user.agent? && record.respond_to?(:end_user?) && record.end_user?
      true
    # end_users cannot create/update/delete users
    else
      false
    end
  end
  
  def is_current_user?
    user == record
  end
  
end