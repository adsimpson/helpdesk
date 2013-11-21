require 'spec_helper'

module PasswordResetTokensControllerHelpers
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
end

describe Api::V1::PasswordResetTokensController do
  extend PasswordResetTokensControllerHelpers
  render_views
  let(:user) { FactoryGirl.create :user }
  
  describe "#create" do
    let(:action) { post :create, email: user_email }
    let(:user_email) { user.email }
    
    does_not_require_authentication
    creates_resource
    returns_http_status 201
    returns_empty_json_payload

    context "exception handling - when password reset service is not active" do
      before { PasswordResetService.stub(:active?).and_return(false) }
      does_not_create_resource
      returns_http_status 404
    end
    context "exception handling - when email is blank" do
      let(:user_email) { " " }
      does_not_create_resource
      returns_http_status 400
    end
    context "exception handling - when email is not recognized" do
      let(:user_email) { "unknown@example.com" }
      does_not_create_resource
      returns_http_status 201
    end
  end
  
  describe "#show" do
    let(:action) { get :show, id: resource.token }
    let!(:resource) { FactoryGirl.create :password_reset_token, user: user }
    
    does_not_require_authentication
    does_not_modify_resource
    does_not_delete_resource
    returns_http_status 200

    it "returns the token expiry timestamp in the JSON payload" do
      action
      expires_at = parse_json(response.body, "password_reset/expires_at")
      expect(expires_at).to eq resource.expires_at.as_json
    end
    context "exception handling - when password reset service is not active" do
      before { PasswordResetService.stub(:active?).and_return(false) }
      returns_http_status 404
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
  end
  
  describe "#update" do
    let(:action) { put :update, id: resource.token, password: password, password_confirmation: password_confirmation }
    let!(:resource) { FactoryGirl.create :password_reset_token, user: user }
    let(:password) { User.random_password }
    let(:password_confirmation) { password }
    
    does_not_require_authentication
    deletes_resource
    updates_password
    returns_http_status 204
    returns_empty_json_payload
    
    context "exception handling - when password reset service is not active" do
      before { PasswordResetService.stub(:active?).and_return(false) }
      does_not_delete_resource
      does_not_update_password
      returns_http_status 404
    end
    context "exception handling - when token doesn't exist" do
      before { resource.destroy }
      does_not_update_password
      returns_http_status 404
    end
    context "exception handling - when token has expired" do
      before { Timecop.freeze(resource.expires_at + 1.minute) }
      after { Timecop.return }
      does_not_delete_resource
      does_not_update_password
      returns_http_status 404
    end
    context "exception handling - when 'password' is invalid" do
      let(:password) { "a" }
      does_not_delete_resource
      does_not_update_password
      returns_http_status 422
    end
    context "exception handling - when 'password' and 'password_confirmation' do not match" do
      let(:password_confirmation) { User.random_password }
      does_not_delete_resource
      does_not_update_password
      returns_http_status 422
    end    
    context "exception handling - when 'password' is blank" do
      let(:password) { " " }
      does_not_delete_resource
      does_not_update_password
      returns_http_status 400
    end        
  end

end