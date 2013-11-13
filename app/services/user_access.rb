class UserAccess
  
  attr_reader :user
  
  def initialize(user)
    @user = user
  end
  
  def suspended?
    user.active == false
  end
  
  def verified?
    user.verified
  end
  
end