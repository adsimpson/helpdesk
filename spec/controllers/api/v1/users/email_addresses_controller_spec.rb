require 'spec_helper'

describe Api::V1::Users::EmailAddressesController do
  render_views
  describe "#index" do
  end
  
  describe "#show" do
    let(:user) { FactoryGirl.create :user }
    let!(:resource) { FactoryGirl.create :email_address, user: user }
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
    context "exception handling - when email_address doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
    context "exception handling - when email_address doesn't belong to user" do
      let(:another_user) { FactoryGirl.create :user }
      before { resource.update_attributes(user: another_user) }
      returns_http_status 404
      does_not_delete_resource
    end  
  end
  
  describe "#create" do
    let!(:user) { FactoryGirl.create :user }
    let(:action) { post :create, user_id: user.id, email_address: parameters }
    let(:parameters) { {value: "me@example.com"} }
    
    requires_authorization :agent, :admin
    creates_resource
    returns_http_status 201
    returns_resource_in_json_payload
    
    it "allows end_users to create email addresses for themselves" do
      sign_in user
      expect { action }.to change { resource_class.count }.by(1)
    end
    context "when email verification service is not active" do
      before { EmailVerificationService.stub(:active?).and_return(false) }
      it "sets the email address as verified" do
        stub_authorization
        action
        expect(resource.verified).to be_true
      end
    end
    context "when 'verified' parameter == false" do
      before { parameters[:verified] = false }
      it "initiates the email verification workflow" do
        stub_authorization
        expect { action }.to change { EmailVerificationToken.count }.by(1)
      end
    end
    context "when 'verified' parameter == true" do
      before { parameters[:verified] = true }
      it "bypasses the email verification workflow" do
        stub_authorization
        expect { action }.to_not change { EmailVerificationToken.count }
      end
    end
    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
    context "exception handling - when parameters are missing" do
      let(:parameters) { nil }
      returns_http_status 400
      does_not_create_resource
    end  
  end
  
  describe "#update" do
    let(:user) { FactoryGirl.create :user, role: "end_user" }
    let!(:resource) { FactoryGirl.create :email_address, user: user }
    let(:action) { put :update, user_id: user.id, id: resource.id, email_address: parameters } 
    let(:parameters) { {verified: true, primary: true} }
    
    requires_authorization :agent, :admin
    modifies_resource    
    returns_http_status 200
    returns_resource_in_json_payload

    it "does not allow an unverified email address to be set as primary" do
      stub_authorization
      parameters.merge!(verified: false)
      expect { action }.to_not change { resource.reload.primary }.from(false).to(true)
    end
    it "ignores the 'primary' parameter if set to false" do
      stub_authorization
      resource.update_attributes(primary: true)
      parameters.merge!(primary: false)
      expect { action }.to_not change { resource.reload.primary }
    end
    it "allows end_users to set their own verified email address to primary" do
      resource.update_attributes(verified: true)
      sign_in user
      expect { action }.to change { resource.reload.primary }.from(false).to(true)
    end
    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
    context "exception handling - when email_address doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
    context "exception handling - when email_address doesn't belong to user" do
      let(:another_user) { FactoryGirl.create :user }
      before { resource.update_attributes(user: another_user) }
      returns_http_status 404
      does_not_delete_resource
    end  
  end
  
  describe "#destroy" do
    let(:user) { FactoryGirl.create :user, role: "end_user" }
    let!(:primary_resource) { FactoryGirl.create :email_address, user: user }
    let!(:resource) { FactoryGirl.create :email_address, user: user }
    let(:action) { delete :destroy, user_id: user.id, id: resource.id }
    
    requires_authorization :agent, :admin
    deletes_resource
    returns_http_status 204
    returns_empty_json_payload
    
    it "allows end_users to delete their own email addresses" do
      sign_in user
      expect { action }.to change { resource_class.count }.by(-1)
    end
    it "does not allow deletion of the primary email address" do
      resource.update_attributes(primary: true)
      sign_in_as :admin
      expect { action }.to_not change { resource_class.count }
    end
    it "does not allow agents to delete email addresses of other agents or admins" do
      user.update_attributes(role: ["agent", "admin"].sample)
      sign_in_as :agent
      expect { action }.to_not change { resource_class.count }
    end    
    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
    context "exception handling - when email_address doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
    context "exception handling - when email_address doesn't belong to user" do
      let(:another_user) { FactoryGirl.create :user }
      before { resource.update_attributes(user: another_user) }
      returns_http_status 404
      does_not_delete_resource
    end

  end
  
end