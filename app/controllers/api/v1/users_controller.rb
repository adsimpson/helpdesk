class Api::V1::UsersController < Api::V1::BaseController
  before_action :load_user, :except => [:index, :show_current_user, :create]

  def index
    authorize User
    render :json => User.all
  end
  
  def show
    authorize @user
    render :json => @user
  end
  
  def show_current_user
    authorize current_user
    render :json => current_user
  end  
  
  def create
    @user = User.new
    authorize @user
    
    requires_verification = EmailVerification.service_active? && !@user.verified
    @user.verified = true unless requires_verification
     
    if @user.update_attributes permitted_params
      EmailVerification.new(@user).send_instructions if requires_verification
      render :json => @user, :status => :created  
    else
      error!(:invalid_resource, @user.errors, "User has not been created")
    end
  end
  
  def update
    authorize @user
    if @user.update_attributes permitted_params
      render :json => @user, :status => :ok
    else
      error!(:invalid_resource, @user.errors, "User has not been updated")
    end
  end
  
  def destroy
    authorize @user
    @user.destroy
    render :json => {}, :status => :no_content
  end
  
private
  
  def load_user
    @user = User.find params[:id]
  end
  
  def permitted_params
    params.require(:user).permit(policy(@user).permitted_attributes)
  end

end