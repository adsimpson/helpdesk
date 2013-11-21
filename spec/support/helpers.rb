module Helpers
  
  def user_roles
    [:end_user, :agent, :admin]
  end
  
  def http_status_text(status)
    case status
      when 200 then "OK"
      when 201 then "Created"
      when 204 then "No Content"
      when 400 then "Bad Request"
      when 401 then "Unauthorized"
      when 403 then "Forbidden"      
      when 404 then "Not Found" 
      when 422 then "Unprocessable Entity"
      else ""
    end
  end
  
  def does_not_require_authentication
    describe "does not require authentication" do
      it "allows unauthenticated access" do
        no_sign_in
        action
        expect(response).to be_success
      end
      user_roles.each do |role|
        it "allows #{role} access" do
          sign_in_as role
          action
          expect(response).to be_success
        end
      end
    end
  end
  
  def requires_authentication_only
    describe "requires authentication only" do
      it "blocks unauthenticated access" do
        no_sign_in
        action
        expect(response.status).to eq 401
      end
      user_roles.each do |role|
        it "allows #{role} access" do
          sign_in_as role
          action
          expect(response).to be_success
        end
      end
    end
  end
        
  def requires_authorization(*restricted_roles)
    describe "requires authorization" do
      it "blocks unauthenticated access" do
        no_sign_in
        action
        expect(response.status).to eq 401
      end
      user_roles.each do |role|
        if restricted_roles.include? role
          it "allows #{role} access" do
            sign_in_as role
            action
            expect(response).to be_success
          end
        else
          it "blocks #{role} access" do
            sign_in_as role
            action
            expect(response.status).to eq 403
          end
        end
      end
    end
  end
        
  def returns_http_status(status)
    if status == :success
      it "returns a HTTP success status" do
        stub_authorization
        action
        expect(response).to be_success
      end
    else
      it "returns HTTP status #{status} (#{http_status_text(status)})" do
        stub_authorization
        action
        expect(response.status).to eq status
      end  
    end
  end
  
  def returns_empty_json_payload
    it "returns empty JSON payload" do
      stub_authorization
      action
      expect(response.body).to be_json_eql({})
    end
  end
  
  def returns_resource_in_json_payload(options={})
    it "returns the resource in the JSON payload" do
      stub_authorization
      action
      root_element = case
        when options[:root_element] == false then false
        when options[:root_element].present? then options[:root_element].to_s
        else resource.class.name.underscore.downcase
      end
      path = "id"
      path.insert(0, "#{root_element}/") unless root_element == false
      expect(response.body).to be_json_eql(resource.reload.id.to_s).at_path(path)
    end
  end
        
  def returns_resource_list_in_json_payload(options={})
    it "returns the resource list in the JSON payload" do
      resource_class = resource_list.first.class
      stub_authorization
      action
      root_element = case
        when options[:root_element] == false then false
        when options[:root_element].present? then options[:root_element].to_s
        else resource_class.name.underscore.downcase.pluralize
      end
      resource_list.each_with_index do |resource, index|
        path = "#{index}/id"
        path.insert(0, "#{root_element}/") unless root_element == false
        expect(response.body).to be_json_eql(resource.reload.id.to_s).at_path(path)
      end
    end
  end    
        
  def creates_resource
    it "creates the resource" do
      stub_authorization
      expect { action }.to change { resource_class.count }.by(1)
    end
  end
        
  def does_not_create_resource
    it "does not create the resource" do
      stub_authorization
      expect { action }.to_not change { resource_class.count }
    end
  end
        
  def modifies_resource
    it "modifies the resource" do
      stub_authorization
      previously_updated_at = resource.updated_at
      Timecop.travel(Time.now + 1.minute) { action }
      expect(resource.reload.updated_at > previously_updated_at).to be_true
    end
  end
        
  def does_not_modify_resource
    it "does not modify the resource" do
      stub_authorization
      previously_updated_at = resource.updated_at
      Timecop.travel(Time.now + 1.minute) { action }
      expect(resource.reload.updated_at.to_s == previously_updated_at.to_s).to be_true
    end
  end
        
  def deletes_resource
    it "deletes the resource" do
      stub_authorization
      action
      found_resource = resource.class.where(id: resource.id).first
      expect(found_resource).to be_nil
    end
  end

 def does_not_delete_resource
    it "does not delete the resource" do
      stub_authorization
      action
      found_resource = resource.class.where(id: resource.id).first
      expect(found_resource).to eq resource
    end
  end
end


RSpec.configure do |config|
  config.extend Helpers
end