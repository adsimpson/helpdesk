class Api::V1::Users::AuthenticationsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, :only => [:create]
  skip_before_action :authorize_user!, :only => [:create]
  skip_after_action :verify_authorized

  def create
    @user_authentication = UserAuthentication.from_email user_params[:email]
    error! :unauthenticated, 'Invalid credentials' unless user_authentication.authenticate user_params[:password]
    authorize_user!
    user_authentication.sign_in
    render :json => current_user, :serializer => Api::V1::Users::AuthenticationSerializer, :status => :created
  end
  
  def destroy
    user_authentication.sign_out
    render :json => {}, :status => :no_content
  end
  
private
  
  def user_params
    params.require(:user).permit(:email, :password)
  end
  
end