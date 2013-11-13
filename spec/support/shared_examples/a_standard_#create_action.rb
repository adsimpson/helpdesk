shared_examples_for "a standard #create action" do |resource_name=nil, root_element=nil|
  resource_name ||= described_class.controller_name.singularize
  resource_class = resource_name.classify.constantize
  root_element ||= resource_name.to_s

  context "with no parameters" do
    let(:action) { post :create }
    it "does NOT persist the resource" do
      expect { action }.to_not change { resource_class.count }
    end
    it "returns HTTP status 400 (Bad Request)" do
      expect(action.status).to eq 400
    end  
  end

  context "with invalid parameters" do
    let(:parameters) { invalid_parameters }
    it "assigns the new resource to an instance variable (@#{resource_name})" do
      action
      expect(assigns(resource_name)).to be_a(resource_class)
    end
    it "calls 'save' on the resource" do
      resource_class.any_instance.should_receive(:save)
      action
    end
    it "does NOT persist the resource" do
      expect { action }.to_not change { resource_class.count }
    end
    it "returns HTTP status 422 (Unprocessable Entity)" do
      expect(action.status).to eq 422
    end  
  end
  
  context "with valid parameters" do
    let(:resource) { resource_class.last }
    it "assigns the new resource to an instance variable (@#{resource_name})" do
      action
      expect(assigns(resource_name)).to be_a(resource_class)
    end
    it "calls 'save' on the resource" do
      resource_class.any_instance.should_receive(:save)
      action
    end
    it "persists the resource" do
      expect { action }.to change { resource_class.count }.by(1)
    end
    it "returns HTTP status 201 (Created)" do
      expect(action.status).to eq 201
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