class Api::V1::GroupsController < Api::V1::BaseController
  before_action :load_group, :except => [:index, :create]

  def index
    authorize Group
    render :json => Group.all
  end
  
  def show
    authorize @group
    render :json => @group
  end
  
  def create
    @group = Group.new 
    authorize @group
    if @group.update_attributes permitted_params
      render :json => @group, :status => :created  
    else
      error!(:invalid_resource, @group.errors, 'Group has not been created')
    end
  end
  
  def update
    authorize @group
    if @group.update_attributes permitted_params
      render :json => @group, :status => :ok
    else
      error!(:invalid_resource, @group.errors, 'Group has not been updated')
    end
  end
  
  def destroy 
    authorize @group
    @group.destroy
    render :json => {}, :status => :no_content
  end

private
  
  def load_group
    @group = Group.find params[:id]
  end
  
  def permitted_params
    params.require(:group).permit(policy(@group).permitted_attributes)
  end

 
end