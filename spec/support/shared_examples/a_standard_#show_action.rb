shared_examples_for "a standard #show action" do |resource_name=nil, root_element=nil|
  resource_name ||= described_class.controller_name.singularize
  resource_class = resource_name.classify.constantize
  root_element ||= resource_name.to_s
  
  context "when resource does NOT exist" do
    before { resource.destroy }
    it "raises a 'RecordNotFound' error" do
      resource_class.should_receive(:find).with(resource.id.to_s).and_raise(ActiveRecord::RecordNotFound)
      action
    end
    it "does NOT assign the resource to an instance variable" do
      action
      expect(assigns(resource_name)).to be_nil
    end
    it "returns HTTP status 404 (Not Found)" do
      expect(action.status).to eq 404
    end
  end
  context "when resource exists" do
    it "returns HTTP status 200 (OK)" do
      expect(action.status).to eq 200
    end
    it "finds and returns the resource via its class (#{resource_class.name})" do
      resource_class.should_receive(:find).with(resource.id.to_s).and_return(resource)
      action
    end
    it "assigns the resource to an instance variable (@#{resource_name})" do
      action
      expect(assigns(resource_name)).to eq resource
    end
    it "does NOT delete the resource" do
      action
      found_resource = resource_class.where(id: resource.id).first
      expect(found_resource).to eq resource
    end
    it "does NOT update the resource" do
      expect { action }.to_not change { resource.updated_at.to_s }
    end
    it "returned json contains the correct root element (#{root_element})" do
      expect(action.body).to have_json_path(root_element)
    end
    it "returned json contains a single record" do
      expect(action.body).to have_json_size(1)
    end
    it "returned json contains the correct id" do
      expect(action.body).to be_json_eql(resource.id.to_s).at_path("#{root_element}/id")
    end
    it "returned json contains the correct data" do
      expect(action.body).to include_json(resource.to_json)
    end
 
  end
end


