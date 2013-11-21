class Api::V1::AccessTokensController < Api::V1::BaseController
  skip_before_action :authenticate_user!, :only => [:create]
  skip_before_action :authorize_user!, :only => [:create]
  skip_after_action :verify_authorized

  def create
    p = permitted_params
    @user_access_service = UserAccessService.from_email p[:email]
    error! :unauthenticated, 'Invalid credentials' unless user_access_service.authenticate p[:password]
    error! :forbidden, 'Your user account is suspended' if user_access_service.suspended?
    error! :forbidden, 'Your user account is not verified' unless user_access_service.verified?
    @token = user_access_service.sign_in
    render :json => @token, :status => :created
  end
  
  def destroy
    user_access_service.sign_out
    render :json => {}, :status => :no_content
  end
  
private
  
  def permitted_params
    params.require(:user).permit(:email, :password)
  end
  
end