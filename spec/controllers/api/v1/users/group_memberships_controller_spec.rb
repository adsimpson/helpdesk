require 'spec_helper'

describe Api::V1::Users::GroupMembershipsController do
  render_views
  
  describe "#index" do
    let(:user) { FactoryGirl.create :user, role: "agent" }
    let(:resource_list) { FactoryGirl.create_list :group_membership, 3, user: user }
    let(:action) { get :index, user_id: user.id }
    
    requires_authorization :agent, :admin
    returns_resource_list_in_json_payload
    returns_http_status 200
    
    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
  end

  describe "#index_groups" do
    let(:user) { FactoryGirl.create :user, role: "agent" }
    let!(:group_memberships) { FactoryGirl.create_list :group_membership, 3, user: user }
    let(:resource_list) { user.groups }
    let(:action) { get :index_groups, user_id: user.id }
    
    requires_authorization :agent, :admin
    returns_resource_list_in_json_payload
    returns_http_status 200
    
    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
  end

  describe "#show" do
    let(:user) { FactoryGirl.create :user, role: "agent" }
    let!(:resource) { FactoryGirl.create :group_membership, user: user }
    let(:action) { get :show, user_id: user.id, id: resource.id }
    
    requires_authorization :agent, :admin
    does_not_modify_resource
    does_not_delete_resource
    returns_http_status 200
    returns_resource_in_json_payload

    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
    context "exception handling - when group_membership doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
    context "exception handling - when group_membership doesn't involve user" do
      let(:another_user) { FactoryGirl.create :user, role: "agent" }
      before { resource.update_attributes(user: another_user) }
      returns_http_status 404
    end
  end
  
  describe "#create" do
    let(:user) { FactoryGirl.create :user, role: "agent" }
    let(:group) { FactoryGirl.create :group }
    let(:action) { post :create, user_id: user.id, group_membership: parameters }
    let(:parameters) { {group_id: group.id} }
    
    requires_authorization :admin
    creates_resource
    returns_http_status 201
    returns_resource_in_json_payload
    
    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
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
    let(:user) { FactoryGirl.create :user, role: "agent" }
    let!(:resource) { FactoryGirl.create :group_membership, user: user }
    let(:action) { delete :destroy, user_id: user.id, id: resource.id }
    
    requires_authorization :admin
    deletes_resource
    returns_http_status 204
    returns_empty_json_payload
    
    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
    context "exception handling - when group_membership doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
    context "exception handling - when group_membership doesn't involve user" do
      let(:another_user) { FactoryGirl.create :user, role: "agent" }
      before { resource.update_attributes(user: another_user) }
      returns_http_status 404
      does_not_delete_resource
    end

  end
  
  describe "#set_default" do
    let(:user) { FactoryGirl.create :user, role: "agent" }
    let!(:resource) { FactoryGirl.create :group_membership, user: user }
    let(:action) { put :set_default, user_id: user.id, id: resource.id }
    
    requires_authorization :admin
    returns_http_status 200
    returns_resource_in_json_payload
    
    context "when already the user's default" do
      before { resource.update_attributes(default: true) }
      does_not_modify_resource
    end
    context "when not the user's default" do
      before { resource.update_attributes(default: false) }
      let!(:default_membership) { FactoryGirl.create :group_membership, user: user, default: true }
      modifies_resource
      it "sets 'default' on the membership to true" do
        stub_authorization
        expect { action }.to change { resource.reload.default }.to true
      end
      it "sets 'default' on the previous default membership to false" do
        stub_authorization
        expect { action }.to change { default_membership.reload.default }.to false
      end
    end
    
    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
    context "exception handling - when group_membership doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
    context "exception handling - when group_membership doesn't involve user" do
      let(:another_user) { FactoryGirl.create :user, role: "agent" }
      before { resource.update_attributes(user: another_user) }
      returns_http_status 404
      does_not_delete_resource
    end
  end

end