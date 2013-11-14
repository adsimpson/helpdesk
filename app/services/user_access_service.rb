class UserAccessService
  
  attr_reader :user
  
  def initialize(user)
    @user = user
  end
  
  def user_suspended?
    user.active == false
  end
  
  def user_verified?
    user.verified
  end
  
end