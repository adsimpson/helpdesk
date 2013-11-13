class Api::V1::GroupMembershipsController < Api::V1::BaseController
  before_action :load_group_membership, :except => [:index, :create]

  def index
    authorize GroupMembership
    render :json => GroupMembership.all
  end

  def show
    authorize @group_membership
    render :json => @group_membership
  end
  
  def create
    @group_membership = GroupMembership.new
    authorize @group_membership
    if @group_membership.update_attributes permitted_params
      render :json => @group_membership, :status => :created  
    else
      error!(:invalid_resource, @group_membership.errors, 'Group Membership has not been created')
    end
  end
  
  def destroy 
    authorize @group_membership
    @group_membership.destroy
    render :json => {}, :status => :no_content
  end
  
private
  
  def load_group_membership
    @group_membership = GroupMembership.find params[:id]
  end
  
  def permitted_params
    params.require(:group_membership).permit(policy(@group_membership).permitted_attributes)
  end
   
end