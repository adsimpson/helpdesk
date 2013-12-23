class ApplicationPolicy
  attr_reader :user,  # User performing the action
              :record # Instance upon which action is performed
 
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "Must be signed in." unless user
    @user   = user
    @record = record
  end
 
  def index?  ; admin? || agent?;   end
  def show?   ; admin? || agent?;   end
  def create? ; admin?;   end
  def update? ; admin?;   end
  def destroy?; admin?;   end
 
  def scope
    Pundit.policy_scope!(user, record.class)
  end
    
  def permitted_attributes
    []
  end
    
private
    
  def end_user?
    user.end_user?
  end
    
  def agent?
    user.agent?
  end
    
  def admin?
    user.admin?
  end

  def new_record?
    record.respond_to?(:new_record?) && record.new_record?
  end

end