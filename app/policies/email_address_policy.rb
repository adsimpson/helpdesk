class EmailAddressPolicy < ApplicationPolicy

  def show?
    # end_users can only view their own email address records
    record_is_for?(:current_user) ? true : user.end_user? ? false : true
  end
  
  def create?
    default_permissions
  end
  
  def update?
    default_permissions
  end
  
  def destroy?
    # cannot delete the primary email address
    record.primary == true ? false : default_permissions
  end
  
  def make_primary?
    # cannot set an unverified email address as primary
    record.verified == true ? default_permissions : false
  end
  
  def permitted_attributes
    # value is only permitted when creating a new record
    # users cannot set their own email addresses as verified
    # controller ensures primary can only be true
    attrs = [:primary]
    attrs << :value if record.new_record?
    attrs << :verified unless record_is_for?(:current_user)
    attrs
  end

private
  
  def default_permissions
    # all users can crud email addresses for themselves
    # admins can crud email addresses for all users
    # agents can only crud email addresses for end_users
    # end_users cannot crud email addresses for anyone else
    case
      when record_is_for?(:current_user) then true
      when user.admin? then true
      when user.agent? then record_is_for?(:end_user)
      else false
    end
  end
  
  def record_is_for?(role)
    case 
      when record.respond_to?(:user) == false then false
      when role == :current_user then (record.user == user)
      else record.user.role?(role)
    end
  end
  
end