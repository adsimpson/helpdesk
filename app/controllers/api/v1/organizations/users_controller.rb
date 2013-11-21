class Api::V1::Organizations::UsersController < Api::V1::BaseController
  before_action :load_organization
  
  # returns a list of users for the organization
  def index
    authorize @organization
    render :json => @organization.users
  end
  
private
  
  def load_organization
    @organization = Organization.find params[:organization_id]
  end
  
end