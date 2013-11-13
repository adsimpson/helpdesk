shared_examples_for "a standard #destroy action" do |resource_name=nil, root_element=nil|
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
    it "returns HTTP status 204 (No Content)" do
      expect(action.status).to eq 204
    end
    it "finds and returns the resource via its class (#{resource_class.name})" do
      resource_class.should_receive(:find).with(resource.id.to_s).and_return(resource)
      action
    end
    it "assigns the resource to an instance variable (@#{resource_name})" do
      action
      expect(assigns(resource_name)).to eq resource
    end
    it "calls 'destroy' on the resource" do
      resource_class.any_instance.should_receive(:destroy)
      action
    end
    it "deletes the resource" do
      action
      found_resource = resource_class.where(id: resource.id).first
      expect(found_resource).to be_nil
    end
    it "returned json is empty" do
      expect(action.body).to be_json_eql({})
    end
  end
end
