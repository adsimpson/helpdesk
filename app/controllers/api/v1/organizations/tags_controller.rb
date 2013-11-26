class Api::V1::Organizations::TagsController < Api::V1::BaseController
  before_action :load_organization
  before_action :load_tag_params
  
  # returns a list of tags for the organization
  def index
    authorize @organization
    render :json => @organization.tags
  end

  # sets tags for organization (replacing any existing tags)
  def create
    authorize @organization
    if @organization.update_attributes(tag_list: @tags)
      render :json => @organization.reload.tags, :status => :created
    else
      error!(:invalid_resource, @organization.errors, "Tags have not been saved")
    end
  end

  # adds tags to organization (appended to any existing tags)
  def update
    authorize @organization
    @organization.tag_list.add @tags
    if @organization.save
      render :json => @organization.reload.tags
    else
      error!(:invalid_resource, @organization.errors, "Tags have not been saved")
    end
  end
  
  # remove named tags (if any), else all tags
  def destroy
    authorize @organization
    @tags = @organization.tag_list if @tags.empty?
    @organization.tag_list.remove @tags
    if @organization.save
      render :json => @organization.reload.tags
    else
      error!(:invalid_resource, @organization.errors, "Tags have not been saved")
    end
  end

private
  
  def load_organization
    @organization = Organization.find params[:organization_id]
  end
  
  def load_tag_params
    @tags = permitted_params[:tags]
    @tags = [] if @tags.nil?
  end
  
  def permitted_params
    params.permit([:tags => []])
  end
  
end