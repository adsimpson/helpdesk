require 'spec_helper'

describe Api::V1::AccessTokensController do
  render_views
  
  describe "#create" do
    let(:action) { post :create, user: parameters }
    let(:parameters) { {email: user.email, password: user.password} }
    let(:user) { FactoryGirl.create :user, verified: true }
    
    returns_http_status 201
    creates_resource
    
    it "returns the access token in the JSON payload" do
      action
      access_token = parse_json(response.body, "access/token")
      expect(AccessToken.encrypt(access_token)).to eq resource.token_digest      
    end
    context "exception handling - when user credentials are incorrect (email)" do
      before { parameters[:email] = "unknown@example.com" }
      returns_http_status 401
      does_not_create_resource
    end
    context "exception handling - when user credentials are incorrect (password)" do
      before { parameters[:password] = User.random_password }
      returns_http_status 401
      does_not_create_resource
    end
    context "exception handling - when user is not verified" do
      before { user.update_attributes(verified: false) }
      returns_http_status 403
      does_not_create_resource
    end
    context "exception handling - when user is suspended" do
      before { user.update_attributes(active: false) }
      returns_http_status 403
      does_not_create_resource
    end
  end
  
  describe "#destroy" do
    let(:action) { delete :destroy }
    let(:user) { FactoryGirl.create :user, verified: true }
    let(:resource) { FactoryGirl.create :access_token, user: user }
    before { request.headers["Authorization"] = "Token #{resource.token}" }
    
    requires_authentication_only
    returns_http_status 204
    returns_empty_json_payload
    deletes_resource
  end
  
end

