require 'spec_helper'

describe Api::V1::Users::TagsController do
  render_views
  
  describe "#index" do
    let(:user) { FactoryGirl.create :user, tag_list: tags }
    let(:tags) { ["a", "b", "c"] }
    let(:action) { get :index, user_id: user.id }
    
    requires_authorization :agent, :admin
    #returns_resource_list_in_json_payload
    returns_http_status 200
    
    it "returns all tags in the JSON payload" do
      stub_authorization
      action
      expect(response.body).to be_json_eql(tags).at_path("tags")
    end
    
    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
  end
  
  describe "#create" do
    let(:user) { FactoryGirl.create :user, tag_list: old_tags }
    let(:old_tags) { ["a", "b", "c"] }
    let(:new_tags) { ["d", "e", "f","g"] }
    let(:action) { post :create, user_id: user.id, tags: new_tags }
    
    returns_http_status 201

    it "replaces any existing tags with the supplied tag list" do
      stub_authorization
      expect { action }.to change { user.reload.tag_list }.from(old_tags).to(new_tags)
    end
    it "returns all tags in the JSON payload" do
      stub_authorization
      action
      expect(response.body).to be_json_eql(new_tags).at_path("tags")
    end
    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
  end

  describe "#update" do
    let(:user) { FactoryGirl.create :user, tag_list: old_tags }
    let(:old_tags) { ["a", "b", "c"] }
    let(:new_tags) { ["d", "e", "f", "g"] }
    let(:combined_tags) { old_tags + new_tags }
    let(:action) { put :update, user_id: user.id, tags: new_tags }
    
    returns_http_status 200

    it "appends the supplied tag list to any existing tags" do
      stub_authorization
      expect { action }.to change { user.reload.tag_list }.from(old_tags).to(combined_tags)
    end
    it "returns all tags in the JSON payload" do
      stub_authorization
      action
      expect(response.body).to be_json_eql(combined_tags).at_path("tags")
    end
    context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
  end

  describe "#delete" do
    let(:user) { FactoryGirl.create :user, tag_list: tags }
    let(:tags) { ["a", "b", "c", "d"] }
    let(:delete_tags) { ["a", "c"] }
    let(:remaining_tags) { tags - delete_tags }
    let(:action) { delete :destroy, user_id: user.id, tags: delete_tags }
    
    returns_http_status 200
    
    it "deletes the supplied tag list from the existing tags" do
      stub_authorization
      expect { action }.to change { user.reload.tag_list }.from(tags).to(remaining_tags)
    end
    it "returns all remaining tags in the JSON payload" do
      stub_authorization
      action
      expect(response.body).to be_json_eql(remaining_tags).at_path("tags")
    end
    context "when the supplied tag list is empty" do
      let(:delete_tags) { [] }
      it "deletes all existing tags" do
        stub_authorization
        expect { action }.to change { user.reload.tag_list }.from(tags).to([])
      end
    end
     context "exception handling - when user doesn't exist" do
      before { user.destroy }
      returns_http_status 404
    end
  end
  
end