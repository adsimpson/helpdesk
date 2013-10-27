class Api::V1::UsersController < Api::V1::BaseController
  before_action :load_user, :only => :create 
  load_and_authorize_resource :except => :show_current_user

  def index
    render :json => @users
  end
  
  def show
    render :json => @user
  end
  
  def show_current_user
    render :json => current_user
  end  
  
  def create
    requires_verification = EmailVerification.service_active? && !@user.verified
    @user.verified = true unless requires_verification
     
    if @user.save
      EmailVerification.new(@user).send_instructions if requires_verification
      render :json => @user, :status => :created  
    else
      error!(:invalid_resource, @user.errors, "User has not been created")
    end
  end
  
  def update
    @user.assign_attributes user_params
    restrict_attributes_for_update!
    if @user.save
      render :json => @user, :status => :ok
    else
      error!(:invalid_resource, @user.errors, "User has not been updated")
    end
  end
  
  def destroy
    @user.destroy
    render :json => {}, :status => :no_content
  end
  
protected
  
  # hack to load resource on :create & thus get round CanCan's lack of support for Strong Parameters
  def load_user
    @user = User.new user_params
  end
  
  def user_params
    params.require(:user).permit(:name, :email, :role, :active, :verified,
      :password, :password_confirmation, :organization_id)
  end

  def restrict_attributes_for_update!
    if current_user? @user
      error! :forbidden, "You cannot update your own role" if @user.role_changed?
      error! :forbidden, "You cannot activate or suspend yourself" if @user.active_changed?
      error! :forbidden, "You cannot change your own verification status" if @user.verified_changed?  
    end
    
    if current_user.agent?
      error! :forbidden, "You are not authorized to update user roles" if @user.role_changed?
    end
    
  end
end