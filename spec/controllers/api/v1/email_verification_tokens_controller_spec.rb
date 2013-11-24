require 'spec_helper'

module EmailVerificationTokensControllerHelpers
  def verifies_email_address
    it "verifies the email address" do
      expect { action }.to change { email_address.reload.verified }.to true 
    end
  end
  def does_not_verify_email_address
    it "does not verify the email address" do
      expect { action }.to_not change { email_address.reload.verified }.to true 
    end
  end  
  def updates_password
    it "updates the user's password" do
      expect { action }.to change { user.reload.password_digest }
    end
  end
  def does_not_update_password
    it "does not update the user's password" do
      expect { action }.to_not change { user.reload.password_digest }
    end
  end
  def returns_email_address_in_json_payload
    it "returns the email address resource in the JSON payload" do
      stub_authorization
      action
      expect(response.body).to be_json_eql(email_address.id.to_s).at_path("email_address/id")
    end
  end
end

describe Api::V1::EmailVerificationTokensController do
  extend EmailVerificationTokensControllerHelpers
  render_views
  let(:user) { FactoryGirl.create :user }
  let(:email_address) { user.primary_email_address }
  
  describe "#create" do
    let(:action) { post :create, email: email_address.value }
    let(:user_email) { user.email }
    
    requires_authorization :admin
    creates_resource
    returns_http_status 201
    returns_empty_json_payload    
    
    context "exception handling - when email verification service is not active" do
      before { EmailVerificationService.stub(:active?).and_return(false) }
      returns_http_status 404
      does_not_create_resource
    end
    context "exception handling - when email is blank" do
      before { email_address.value = " " }
      returns_http_status 400
      does_not_create_resource
    end
    context "exception handling - when email is not recognized" do
      before { email_address.value = "unknown@example.com" }
      returns_http_status 404
      does_not_create_resource
    end
    context "exception handling - when email address is already verified" do
      before { email_address.update_attributes(verified: true) }
      returns_http_status 400
      does_not_create_resource
    end
  end
  
  describe "#show" do
    let(:action) { get :show, id: resource.token }
    let!(:resource) { FactoryGirl.create :email_verification_token, email_address: email_address }
    
    does_not_require_authentication
    does_not_modify_resource
    does_not_delete_resource
    returns_http_status 200    
    
    it "returns the token expiry timestamp in the JSON payload" do
      action
      expires_at = parse_json(response.body, "email_verification/expires_at")
      expect(expires_at).to eq resource.expires_at.as_json
    end
    context "exception handling - when token doesn't exist" do
      before { resource.destroy }
      returns_http_status 404
    end
    context "exception handling - when token has expired" do
      before { Timecop.freeze(resource.expires_at + 1.minute) }
      after { Timecop.return }
      returns_http_status 404
    end
    context "exception handling - when email verification service is not active" do
      before { EmailVerificationService.stub(:active?).and_return(false) }
      returns_http_status 404
    end
  end

  describe "#update" do
    let(:action) { put :update, id: resource.token, password: password, password_confirmation: password_confirmation }
    let!(:resource) { FactoryGirl.create :email_verification_token, email_address: email_address }
    let(:password) { User.random_password }
    let(:password_confirmation) { password }
    
    does_not_require_authentication
    deletes_resource
    verifies_email_address
    updates_password
    returns_http_status 200    
    returns_email_address_in_json_payload
    
    context "when 'password' is not provided" do
      let(:password) { " " }
      deletes_resource
      verifies_email_address
      does_not_update_password
      returns_http_status 200
      returns_email_address_in_json_payload
    end
    
    context "exception handling - when email verification service is not active" do
      before { EmailVerificationService.stub(:active?).and_return(false) }
      does_not_delete_resource
      does_not_verify_email_address
      does_not_update_password
      returns_http_status 404
    end
    context "exception handling - when token doesn't exist" do
      before { resource.destroy }
      does_not_verify_email_address
      does_not_update_password
      returns_http_status 404
    end
    context "exception handling - when token has expired" do
      before { Timecop.freeze(resource.expires_at + 1.minute) }
      after { Timecop.return }
      does_not_delete_resource
      does_not_verify_email_address
      does_not_update_password
      returns_http_status 404
    end
    context "exception handling - when 'password' is invalid" do
      let(:password) { "a" }
      does_not_delete_resource
      does_not_verify_email_address
      does_not_update_password
      returns_http_status 422
    end
    context "exception handling - when 'password' and 'password_confirmation' do not match" do
      let(:password_confirmation) { User.random_password }
      returns_http_status 422
      does_not_delete_resource
      does_not_verify_email_address
      does_not_update_password
    end    
  end

end
