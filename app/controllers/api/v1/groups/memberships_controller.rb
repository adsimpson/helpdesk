class Api::V1::Groups::MembershipsController < Api::V1::BaseController
  before_action :load_group
  
  # returns a list of group memberships for the group
  def index
    authorize Group
    render :json => GroupMembership.where(:group => @group)
  end
  
  # returns a list of users [via group memberships] for the group
  def index_users
    authorize Group, :index?
    render :json => @group.users
  end  
  
private
  
  def load_group
    @group = Group.find params[:group_id]
  end
  
end