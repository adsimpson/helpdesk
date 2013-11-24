require 'spec_helper'

describe Api::V1::UsersController do
  render_views
  
  describe "#index" do
    let(:resource_list) { FactoryGirl.create_list :user, 3 }
    let(:action) { get :index }
    
    requires_authorization :agent, :admin
    returns_resource_list_in_json_payload
    returns_http_status 200
  end

  describe "#show" do
    let(:resource) { FactoryGirl.create :user }
    let(:action) { get :show, id: resource.id }
    
    requires_authorization :agent, :admin
    does_not_modify_resource
    does_not_delete_resource
    returns_http_status 200
    returns_resource_in_json_payload

    context "exception handling - when user doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
  end
  
  describe "#create" do
    let(:action) { post :create, user: parameters }
    let(:parameters) { FactoryGirl.attributes_for(:user) }
    before do
      unless parameters.nil?
        parameters[:email] = parameters.fetch(:email_addresses_attributes)[0][:value]
        parameters.delete :email_addresses_attributes 
      end
    end
    
    requires_authorization :agent, :admin
    creates_resource
    returns_http_status 201
    returns_resource_in_json_payload
    
    context "when multiple email addresses are provided" do
      before do
        parameters[:emails] = [ parameters[:email], "another#{parameters[:email]}", "andanother#{parameters[:email]}"  ]
        parameters.delete :email
        stub_authorization
      end
      it "multiple email addresses are linked to the user" do
        action
        expect(resource.email_addresses.count).to eq parameters[:emails].count
      end
      it "the first address is set as the user's primary email" do
        action
        expect(resource.primary_email_address.value).to eq parameters[:emails][0]
      end
      it "all email addresses are set as verified if 'verified' parameter == true" do
        parameters[:verified] = true
        action
        resource.email_addresses.each { |email_address| expect(email_address.verified).to be_true }
      end
    end
    context "when email verification service is not active" do
      before { EmailVerificationService.stub(:active?).and_return(false) }
      it "sets the new user as verified" do
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
    context "when current user is an agent" do
      let(:current_user) { FactoryGirl.create :user, role: "agent" }
      before { parameters[:role] = "agent" }
      it "ignores the 'role' attribute and always creates an end_user" do
        sign_in current_user
        action
        expect { resource.end_user? }.to be_true
      end
    end
    context "exception handling - when parameters are invalid" do
      let(:parameters) { FactoryGirl.attributes_for(:invalid_user) }
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
    let!(:resource) { FactoryGirl.create :user }
    let(:action) { put :update, id: resource.id, user: parameters }
    let(:parameters) { FactoryGirl.attributes_for(:user) }
    
    requires_authorization :agent, :admin
    modifies_resource
    returns_http_status 200
    returns_resource_in_json_payload
    
    it "allows end_users to update themselves" do
      resource.update_attributes(role: "end_user")
      sign_in resource
      previously_updated_at = resource.updated_at
      Timecop.travel(Time.now + 1.minute) { action }
      expect(resource.reload.updated_at > previously_updated_at).to be_true
    end
    context "users updating themselves" do
      before do
        resource.update_attributes(role: "agent")
        sign_in resource
      end
      it "cannot change their own 'role'" do
        parameters[:role] = "admin"
        expect { action }.to_not change { resource.reload.role }  
      end
      it "cannot change their assigned 'organization'" do
        parameters[:organization_id] = FactoryGirl.create(:organization).id
        expect { action }.to_not change { resource.reload.organization }  
      end
      it "cannot change their own 'active' status" do
        parameters[:active] = false
        expect { action }.to_not change { resource.reload.active }  
      end
      it "cannot change their own 'verified' status" do
        parameters[:verified] = false
        expect { action }.to_not change { resource.reload.verified }  
      end
    end
    it "ignores the 'verified' parameter if set to false" do
      stub_authorization
      email_address = resource.primary_email_address
      email_address.update_attributes(verified: true)
      parameters.merge!(verified: false)
      expect { action }.to_not change { email_address.reload.verified }
    end
    it "verifies all user email addresses if the 'verified' parameter if set to true" do
      FactoryGirl.create_list :email_address, 3, user: resource
      stub_authorization
      parameters.merge!(verified: true)
      action
      resource.email_addresses.each { |email_address| expect(email_address.reload.verified).to be_true }
    end
    context "exception handling - when user doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
    context "exception handling - when parameters are invalid" do
      let(:parameters) { FactoryGirl.attributes_for(:invalid_user) }
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
    let(:resource) { FactoryGirl.create :user }
    let(:action) { delete :destroy, id: resource.id }
    
    requires_authorization :agent, :admin
    deletes_resource
    returns_http_status 204
    returns_empty_json_payload
    
    it "does not allow users to delete themselves" do
      resource = FactoryGirl.create :user, role: "admin"
      sign_in resource
      expect { action }.to_not change { resource.class.count }
    end
    it "does not allow agents to delete admins" do
      sign_in_as :agent
      resource.update_attributes(role: "admin")
      expect { action }.to_not change { resource.class.count }
    end
    it "does not allow agents to delete other agents" do
      sign_in_as :agent
      resource.update_attributes(role: "agent")
      expect { action }.to_not change { resource.class.count }
    end
    it "allows agents to delete end_users" do
      sign_in_as :agent
      resource.update_attributes(role: "end_user")
      expect { action }.to change { resource.class.count }.by(-1)
    end
    it "allows admins to delete other admins" do
      sign_in_as :admin
      resource.update_attributes(role: "admin")
      expect { action }.to change { resource.class.count }.by(-1)
    end
    it "allows admins to delete agents" do
      sign_in_as :admin
      resource.update_attributes(role: "agent")
      expect { action }.to change { resource.class.count }.by(-1)
    end
    it "allows admins to delete end_users" do
      sign_in_as :admin
      resource.update_attributes(role: "end_user")
      expect { action }.to change { resource.class.count }.by(-1)
    end
    context "exception handling - when user doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
  end
end