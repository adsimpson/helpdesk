require 'spec_helper'

describe Api::V1::Groups::MembershipsController do
  render_views
  # let(:resource_class) { GroupMembership }
  
  describe "#index" do
    let(:group) { FactoryGirl.create :group }
    let(:resource_list) { FactoryGirl.create_list :group_membership, 3, group: group }
    let(:action) { get :index, group_id: group.id }

    requires_authorization :agent, :admin
    returns_resource_list_in_json_payload
    returns_http_status 200
    
    context "exception handling - when group doesn't exist" do
      before { group.destroy }
      returns_http_status 404
    end
  end
  
  describe "#index_users" do
    let(:group) { FactoryGirl.create :group }
    let!(:group_memberships) { FactoryGirl.create_list :group_membership, 3, group: group }
    let(:resource_list) { group.users }
    let(:action) { get :index_users, group_id: group.id }
    # let(:resource_class) { User }
    
    requires_authorization :agent, :admin
    returns_resource_list_in_json_payload
    returns_http_status 200
    
    context "exception handling - when group doesn't exist" do
      before { group.destroy }
      returns_http_status 404
    end
  end
    
end