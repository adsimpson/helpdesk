class Api::V1::GroupsController < Api::V1::BaseController
  before_action :load_group, :only => [:create]
  load_and_authorize_resource

  def index
    render :json => @groups
  end
  
  def show
    render :json => @group
  end
  
  def create
    if @group.save
      render :json => @group, :status => :created  
    else
      error!(:invalid_resource, @group.errors, 'Group has not been created')
    end
  end
  
  def update
    if @group.update_attributes group_params
      render :json => @group, :status => :ok
    else
      error!(:invalid_resource, @group.errors, 'Group has not been updated')
    end
  end
  
  def destroy 
    @group.destroy
    render :json => {}, :status => :no_content
  end

protected
  
  # hack to load resource on :create & thus get round CanCan's lack of support for Strong Parameters
  def load_group
    @group = Group.new group_params 
  end
  
  def group_params
    params.require(:group).permit(:name)
  end

 
end