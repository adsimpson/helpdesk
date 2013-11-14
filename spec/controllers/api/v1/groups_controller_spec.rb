require 'spec_helper'

describe Api::V1::GroupsController do
  render_views
  
  describe "#index" do
    let(:action) { get :index }
    
    describe "authentication / authorization" do
      it_behaves_like "an agent-restricted action"
    end
    context "when authorized" do
      before { stub_authorization }
      it_behaves_like "a standard #index action"
    end
  end
  
  describe "#show" do
    let(:resource) { FactoryGirl.create :group }
    let(:action) { get :show, id: resource.id }
    
    describe "authentication / authorization" do
      it_behaves_like "an agent-restricted action"
    end
    context "when authorized" do
      before { stub_authorization }
      it_behaves_like "a standard #show action"
    end
  end

  describe "#create" do
    let(:parameters) { FactoryGirl.attributes_for(:group) }
    let(:invalid_parameters) { FactoryGirl.attributes_for(:invalid_group) }
    let(:action) { post :create, group: parameters }
    describe "authentication / authorization" do
      it_behaves_like "an admin-restricted action"
    end
    context "when authorized" do
      before { stub_authorization }
      it_behaves_like "a standard #create action"
    end
  end
  
  describe "#update" do
  end

  describe "#destroy" do
    let(:resource) { FactoryGirl.create :group }
    let(:action) { delete :destroy, id: resource.id }
    
    describe "authentication / authorization" do
      it_behaves_like "an admin-restricted action"
    end
    context "when authorized" do
      before { stub_authorization }
      it_behaves_like "a standard #destroy action"
    end
  end
  
end
  