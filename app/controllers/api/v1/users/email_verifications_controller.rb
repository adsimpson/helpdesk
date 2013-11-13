class Api::V1::Users::EmailVerificationsController < Api::V1::BaseController
  skip_before_action :authenticate_user!, :except => [:create]
  skip_before_action :authorize_user!, :except => [:create]
  skip_after_action :verify_authorized, :except => [:create]
  
  before_action :email_verification_service_active!
  before_action :email_verification_from_token!, :except => [:create]
  
  # returns whether a email verification token is still valid [200] or not found / expired [404]
  def show
    render :json => @user, :serializer => Api::V1::Users::EmailVerificationSerializer
  end

  # creates a new verification token for a specified email address
  def create
    error! :bad_request, 'Email address must be specified' if params[:email].blank?
   
    @email_verification = EmailVerification.from_email params[:email]
    @user = @email_verification.user
    authorize User
    
    error! :not_found, 'Email address is not recognised' if @user.nil?
    error! :bad_request, 'Email address is already verified' if @user.verified
    
    @email_verification.send_instructions
    render :json => {}, :status => :created  
  end
  
  # verifies user - requires matching password & password confirmation to be passed in
  def update
    if @email_verification.update(params[:password], params[:password_confirmation])
      render :json => @user, :status => :ok
    else
      error!(:invalid_resource, @user.errors, 'Email address has not been verified')
    end
  end
  
private
    
  # raises error if email verification workflow not configured
  def email_verification_service_active!
    error! :not_found, 'Email verification service is not active' unless EmailVerification.service_active?
  end
  
  def email_verification_from_token!
    @email_verification = EmailVerification.from_token params[:id]
    @user = @email_verification.user
    error! :not_found, 'Email verification token is invalid' if @user.nil?
    error! :not_found, 'Email verification token has expired' if @email_verification.token_expired?
  end
  
end