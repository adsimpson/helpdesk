class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include CanCan::ControllerAdditions
  include Oops::ControllerAdditions

  map_error! CanCan::AccessDenied, Oops::Forbidden

  before_action :authenticate_user!

  def authentication
    @authentication ||= Authentication.from_token(authenticate_with_http_token { |token| token })
  end

  def current_user
    authentication.user
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def signed_in?
    authentication.signed_in?
  end
  
  def authenticate_user!
   unless signed_in? 
     error! :unauthenticated, 'Authentication token is missing or invalid' 
   end
  end

  def administrators_only!
    authenticate_user!
    unless current_user.admin? 
      error! :forbidden, 'The requested action is accessible to administrators only'
    end
  end
  
  def agents_only!
    authenticate_user!
    unless current_user.admin_or_agent?
      error! :forbidden, 'The requested action is accessible to agents only'
    end
  end
    
end
