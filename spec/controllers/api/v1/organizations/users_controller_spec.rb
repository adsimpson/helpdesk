require 'spec_helper'

describe Api::V1::Organizations::UsersController do
  render_views
  
  describe "#index" do
    let(:organization) { FactoryGirl.create :organization }
    let(:resource_list) { FactoryGirl.create_list :user, 3, organization: organization }
    let(:action) { get :index, organization_id: organization.id }
    
    requires_authorization :agent, :admin
    returns_resource_list_in_json_payload
    returns_http_status 200
    
    context "exception handling - when organization doesn't exist" do
      before { organization.destroy }
      returns_http_status 404
    end
  end
  
end