class Api::V1::Users::GroupMembershipsController < Api::V1::BaseController
  before_action :load_group_membership, :only => [:create]
  load_and_authorize_resource :except => [:index_groups, :set_default]
  load_resource :only => :set_default
  before_action :load_user
  
  def index
    render :json => @group_memberships.where(:user => @user)
  end
  
  def index_groups
    # non-standard action requires :read authorization on the GroupMembership resource
    authorize! :read, GroupMembership
    
    render :json => @user.groups
  end
  
  def show
    render :json => @group_membership
  end
  
  def create
    @group_membership.user = @user

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

  def set_default
    # non-standard action requires :write authorization on the GroupMembership resource
    authorize! :write, GroupMembership
    
    @default = @user.group_memberships.where(:default => true).first
    @default.update_attributes(:default => false) if (@default && @default != @group_membership)
    
    if @group_membership.update_attributes :default => true
      render :json => @group_membership, :status => :ok
    else
      error!(:invalid_resource, @group_membership.errors, 'Group Membership has not been updated')
    end
  end

protected
  
  def load_user
    @user = User.find params[:user_id]
  end
  
  # hack to load resource on :create & thus get round CanCan's lack of support for Strong Parameters
  def load_group_membership
    @group_membership = GroupMembership.new group_membership_params
  end
  
  def group_membership_params
    params.require(:group_membership).permit(:group_id)
  end
  
end