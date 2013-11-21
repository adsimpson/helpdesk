require 'spec_helper'

describe Api::V1::GroupMembershipsController do
  render_views
  
  describe "#index" do
    let(:resource_list) { FactoryGirl.create_list :group_membership, 3 }
    let(:action) { get :index }
    
    requires_authorization :agent, :admin
    returns_resource_list_in_json_payload
    returns_http_status 200
  end

  describe "#show" do
    let(:resource) { FactoryGirl.create :group_membership }
    let(:action) { get :show, id: resource.id }
    
    requires_authorization :agent, :admin
    does_not_modify_resource
    does_not_delete_resource
    returns_http_status 200
    returns_resource_in_json_payload

    context "exception handling - when group_membership doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
  end
  
  describe "#create" do
    let(:resource) { GroupMembership.last }
    let(:action) { post :create, group_membership: parameters }
    let(:parameters) { {user_id: user.id, group_id: group.id} }
    let(:user) { FactoryGirl.create :user, role: "agent" }
    let(:group) { FactoryGirl.create :group }
    
    requires_authorization :admin
    creates_resource
    returns_http_status 201
    returns_resource_in_json_payload

    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 422
      does_not_create_resource
    end
    context "exception handling - when user is an end_user" do
      before { user.update_attributes(role: "end_user") }
      returns_http_status 422
      does_not_create_resource
    end
    context "exception handling - when group doesn't exist" do
      before { group.destroy }
      returns_http_status 422
      does_not_create_resource
    end
    context "exception handling - when parameters are missing" do
      let(:parameters) { nil }
      returns_http_status 400
      does_not_create_resource
    end
  end

  describe "#destroy" do
    let(:resource) { FactoryGirl.create :group_membership }
    let(:action) { delete :destroy, id: resource.id }
    
    requires_authorization :admin
    deletes_resource
    returns_http_status 204
    returns_empty_json_payload
    
    context "exception handling - when group_membership doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
  end

end