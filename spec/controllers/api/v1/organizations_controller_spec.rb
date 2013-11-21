require 'spec_helper'

describe Api::V1::OrganizationsController do
  render_views
  
  describe "#index" do
    let(:resource_list) { FactoryGirl.create_list :organization, 3 }
    let(:action) { get :index }
    
    requires_authorization :agent, :admin
    returns_resource_list_in_json_payload
    returns_http_status 200
  end
  
  describe "#show" do
    let(:resource) { FactoryGirl.create :organization }
    let(:action) { get :show, id: resource.id }
    
    requires_authorization :agent, :admin
    does_not_modify_resource
    does_not_delete_resource
    returns_http_status 200
    returns_resource_in_json_payload
    
    context "exception handling - when organization doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
  end

  describe "#create" do
    let(:action) { post :create, organization: parameters }
    let(:parameters) { FactoryGirl.attributes_for :organization }
    
    requires_authorization :admin
    creates_resource
    returns_http_status 201
    returns_resource_in_json_payload

    context "with embedded domain names" do
      let(:new_domains) { FactoryGirl.build_list :domain, 2 }
      before { parameters[:domains] = new_domains.map { |d| d.name } }
      before { stub_authorization }
      it "creates new domains" do
        action
        expect(resource.domains.count).to eq new_domains.count
      end
    end
    context "exception handling - when parameters are invalid" do
      let(:parameters) { FactoryGirl.attributes_for(:invalid_organization) }
      returns_http_status 422
      does_not_create_resource
    end
    context "exception handling - when parameters are missing" do
      let(:parameters) { nil }
      returns_http_status 400
      does_not_create_resource
    end
  end
  
  describe "#update" do
    let!(:resource) { FactoryGirl.create :organization }
    let(:action) { put :update, id: resource.id, organization: parameters }
    let(:parameters) { FactoryGirl.attributes_for :organization }
    
    requires_authorization :admin
    returns_http_status 200
    modifies_resource
    returns_resource_in_json_payload
    
    context "when organization has associated domains" do
      let!(:resource) { FactoryGirl.create :organization_with_domains, domains_count: 3 }
      let(:saved_domains) { Domain.where(organization: resource) }
      before { stub_authorization }
      context "and no 'domains' parameter is specified" do
        it "retains all domains" do
          expect { action }.to_not change { saved_domains.count }
        end
      end
      context "and only a subset of 'domains' are specified" do
        before { parameters[:domains] = saved_domains.drop(2).map { |d| d.name } }
        it "deletes all unspecified domains" do
          expect { action }.to change { saved_domains.count }.by(-2)
        end
      end
      context "and additional 'domains' are specified" do
        let(:new_domains) { FactoryGirl.build_list :domain, 2 }        
        before { parameters[:domains] = (saved_domains + new_domains).map { |d| d.name } }
        it "creates new domains" do
          expect { action }.to change { saved_domains.count }.by(new_domains.count)
        end
      end
    end
    context "exception handling - when organization doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
    context "exception handling - when parameters are invalid" do
      let(:parameters) { FactoryGirl.attributes_for(:invalid_organization) }
      returns_http_status 422
      does_not_modify_resource
    end
    context "exception handling - when parameters are missing" do
      let(:parameters) { nil }
      returns_http_status 400
      does_not_modify_resource
    end
 end

  describe "#destroy" do
    let(:resource) { FactoryGirl.create :organization }
    let(:action) { delete :destroy, id: resource.id }
    
    requires_authorization :admin
    deletes_resource
    returns_http_status 204
    returns_empty_json_payload
    
    context "when organization has associated domains" do
      let(:resource) { FactoryGirl.create :organization_with_domains, domains_count: 3 }
      let(:saved_domains) { Domain.where(organization: resource) }
      before { stub_authorization }
      it "deletes the domains" do
        expect { action }.to change { saved_domains.count }.from(3).to(0)
      end
    end
    context "exception handling - when organization doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
  end
  
end
  