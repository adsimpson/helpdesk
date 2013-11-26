class Api::V1::Users::TagsController < Api::V1::BaseController
  before_action :load_user
  before_action :load_tag_params
  
  # returns a list of tags for the user
  def index
    authorize @user
    render :json => @user.tags
  end

  # sets tags for user (replacing any existing tags)
  def create
    authorize @user
    if @user.update_attributes(tag_list: @tags)
      render :json => @user.reload.tags, :status => :created
    else
      error!(:invalid_resource, @user.errors, "Tags have not been saved")
    end
  end

  # adds tags to user (appended to any existing tags)
  def update
    authorize @user
    @user.tag_list.add @tags
    if @user.save
      render :json => @user.reload.tags
    else
      error!(:invalid_resource, @user.errors, "Tags have not been saved")
    end
  end
  
  # remove named tags (if any), else all tags
  def destroy
    authorize @user
    @tags = @user.tag_list if @tags.empty?
    @user.tag_list.remove @tags
    if @user.save
      render :json => @user.reload.tags
    else
      error!(:invalid_resource, @user.errors, "Tags have not been saved")
    end
  end

private
  
  def load_user
    @user = User.find params[:user_id]
  end
  
  def load_tag_params
    @tags = permitted_params[:tags]
    @tags = [] if @tags.nil?
  end
  
  def permitted_params
    params.permit([:tags => []])
  end
  
end