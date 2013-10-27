class Api::V1::Users::AuthenticationsController < Api::V1::BaseController
  skip_before_action :authenticate_user! , :only => [:create]

  def create
    @authentication = Authentication.from_email params[:email]

    error! :unauthenticated, 'Invalid credentials' unless @authentication.check_password params[:password]
    error! :forbidden, 'User account is not active' unless @authentication.account_active?
    error! :forbidden, 'User account is not verified' unless @authentication.account_verified?
    
    @authentication.sign_in
    render :json => current_user, :serializer => Api::V1::Users::AuthenticationSerializer, :status => :created
  end
  
  def destroy
    @authentication.sign_out
    render :json => {}, :status => :no_content
  end
  
end