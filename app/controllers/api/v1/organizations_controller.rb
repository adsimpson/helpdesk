class Api::V1::OrganizationsController < Api::V1::BaseController
  before_action :load_organization, :only => [:create]
  load_and_authorize_resource

  def index
    render :json => @organizations
  end
  
  def show
    render :json => @organization
  end
  
  def create
    if @organization.save
      render :json => @organization, :status => :created  
    else
      error!(:invalid_resource, @organization.errors, 'Organization has not been created')
    end
  end
  
  def update
    if @organization.update_attributes organization_params
      render :json => @organization, :status => :ok
    else
      error!(:invalid_resource, @organization.errors, 'Organization has not been updated')
    end
  end
  
  def destroy 
    @organization.destroy
    render :json => {}, :status => :no_content
  end

protected
  
  # hack to load resource on :create & thus get round CanCan's lack of support for Strong Parameters
  def load_organization
    @organization = Organization.new organization_params
  end
  
  def organization_params
    params.require(:organization).permit(:name, :external_id, :notes, :domains => [], :tags => [])
  end

end