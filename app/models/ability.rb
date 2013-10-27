class Ability
  include CanCan::Ability

  def initialize(current_user)
    
    if current_user.admin?
      # administrators
      can :manage, :all
    
    elsif current_user.agent?
      # agents
      can :read, :all 
      # -  can create, update & delete end_users only
      can [:create, :update, :destroy], User, :role => 'end_user'
      
    else
      # end_users
      can :read, User, :id => current_user.id      # can read their own user record
    end
    
    # all users
    #  - can update their own user record [controller defines attribute restrictions until CanCan 2.0]
    can :update, User, :id => current_user.id
    #  - cannot destroy themselves
    cannot :destroy, User, :id => current_user.id  
  end
end
