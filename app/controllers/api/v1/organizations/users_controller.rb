class Api::V1::Organizations::UsersController < Api::V1::BaseController
  load_and_authorize_resource
  before_action :load_organization
  
  # returns a list of users for the organization
  def index
    render :json => @users.where(:organization => @organization)
  end
  
private
  
  def load_organization
    @organization = Organization.find params[:organization_id]
  end
  
end