class ApplicationPolicy
  attr_reader :user,  # User performing the action
              :record # Instance upon which action is performed
 
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "Must be signed in." unless user
    @user   = user
    @record = record
  end
 
  def index?  ; user.admin? || user.agent?;   end
  def show?   ; user.admin? || user.agent?;   end
  def create? ; user.admin?;   end
  def update? ; user.admin?;   end
  def destroy?; user.admin?;   end
 
  def scope
    Pundit.policy_scope!(user, record.class)
  end
    
  def permitted_attributes
    []
  end
end