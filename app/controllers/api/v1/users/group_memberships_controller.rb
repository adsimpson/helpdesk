class Api::V1::Users::GroupMembershipsController < Api::V1::BaseController
  before_action :load_user
  before_action :load_group_membership, :except => [:index, :index_groups, :create]
  
  def index
    authorize User
    render :json => @user.group_memberships
  end
  
  def index_groups
    authorize User, :index?
    render :json => @user.groups
  end
  
  def show
    authorize @group_membership
    render :json => @group_membership
  end
  
  def create
    @group_membership = @user.group_memberships.new
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

  def make_default
    authorize @group_membership
    if @group_membership.update_attributes :default => true
      render :json => @group_membership, :status => :ok
    else
      error!(:invalid_resource, @group_membership.errors, 'Group Membership has not been updated')
    end
  end

private
  
  def load_user
    @user = User.find params[:user_id]
  end
  
  def load_group_membership
    @group_membership = @user.group_memberships.find params[:id]
  end
  
  def permitted_params
    params.require(:group_membership).permit(policy(@group_membership).permitted_attributes)
  end
  
end