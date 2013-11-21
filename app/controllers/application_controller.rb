class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Pundit
  include Oops::ControllerAdditions

  map_error! Pundit::NotAuthorizedError, Oops::Forbidden

  before_action :authenticate_user!
  before_action :authorize_user!
  
  # Verify that controller actions are authorized
  after_action :verify_authorized

  def user_access_service
    @user_access_service ||= UserAccessService.from_token(authenticate_with_http_token { |token| token })
  end

  def current_user
    user_access_service.user
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def signed_in?
    user_access_service.signed_in?
  end
  
  def authenticate_user!
    error! :unauthenticated, 'Authentication token is missing or invalid' unless signed_in? 
  end
  
  def authorize_user!
    error! :forbidden, 'Your user account is suspended' if user_access_service.suspended?
    error! :forbidden, 'Your user account is not verified' unless user_access_service.verified?
  end
end
