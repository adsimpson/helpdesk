class Api::V1::Users::PasswordResetsController < Api::V1::BaseController
  skip_before_action :authenticate_user!
  skip_before_action :authorize_user!
  skip_after_action :verify_authorized
  
  before_action :password_reset_service_active!
  before_action :password_reset_from_token!, :except => [:create]
  
  # returns whether a password reset token is still valid [200] or not found / expired [404]
  def show
    render :json => @user, :serializer => Api::V1::Users::PasswordResetSerializer
  end
  
  # creates a new password reset token for a specified email address
  def create
    error! :bad_request, 'Email address must be specified' if params[:email].blank?
    
    @password_reset = PasswordReset.from_email params[:email]
    @password_reset.send_instructions
    # API provides no indication as to whether a user account exists for the specified email address or not
    render :json => {}, :status => :created  
  end
  
  # updates user password - requires matching password & password confirmation to be passed in
  def update
    if @password_reset.update(params[:password], params[:password_confirmation])
      render :json => {}, :status => :no_content
    else
      error!(:invalid_resource, @user.errors, 'Password has not been reset') 
    end
  end
  
private
  
  # raises error if password reset workflow not configured
  def password_reset_service_active!
    error! :not_found, 'Password reset service is not active' unless PasswordReset.service_active?
  end
  
  def password_reset_from_token!
    @password_reset = PasswordReset.from_token params[:id]
    @user = @password_reset.user
    error! :not_found, 'Password reset token is invalid' if @user.nil?
    error! :not_found, 'Password reset token has expired' if @password_reset.token_expired?
  end
  
end