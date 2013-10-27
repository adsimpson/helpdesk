class Api::V1::GroupMembershipsController < Api::V1::BaseController
  before_action :load_group_membership, :only => [:create]
  load_and_authorize_resource

  def index
    render :json => @group_memberships
  end

  def show
    render :json => @group_membership
  end
  
  def create
    if @group_membership.save
      render :json => @group_membership, :status => :created  
    else
      error!(:invalid_resource, @group_membership.errors, 'Group Membership has not been created')
    end
  end
  
  def destroy 
    @group_membership.destroy
    render :json => {}, :status => :no_content
  end
  
protected
  
  # hack to load resource on :create & thus get round CanCan's lack of support for Strong Parameters
  def load_group_membership
    @group_membership = GroupMembership.new group_membership_params
  end
  
  def group_membership_params
    params.require(:group_membership).permit(:user_id, :group_id)
  end
   
end