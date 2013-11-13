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

  def user_authentication
    @user_authentication ||= UserAuthentication.from_token(authenticate_with_http_token { |token| token })
  end

  def user_access
    @user_access ||= UserAccess.new current_user
  end
  
  def current_user
    user_authentication.user
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def signed_in?
    user_authentication.signed_in?
  end
  
  def authenticate_user!
    unless signed_in?
      error! :unauthenticated, 'Authentication token is missing or invalid'  
    end
  end
  
  def authorize_user!
   error! :forbidden, 'Your user account is suspended' if user_access.suspended?
   error! :forbidden, 'Your user account is not verified' unless user_access.verified?
  end
end
