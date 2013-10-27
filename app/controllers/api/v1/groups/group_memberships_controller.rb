class Api::V1::Groups::GroupMembershipsController < Api::V1::BaseController
  load_and_authorize_resource :except => :index_users
  before_action :load_group
  
  # returns a list of group memberships for the group
  def index
    render :json => @group_memberships.where(:group => @group)
  end
  
  # returns a list of users [via group memberships] for the group
  def index_users
    # non-standard action requires :read authorization on the GroupMembership resource
    authorize! :read, GroupMembership
    
    render :json => @group.users
  end  
  
private
  
  def load_group
    @group = Group.find params[:group_id]
  end
  
end