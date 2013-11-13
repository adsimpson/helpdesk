shared_examples_for "a standard #index action" do |resource_name=nil, root_element=nil|
  resource_name ||= described_class.controller_name.singularize
  resource_class = resource_name.classify.constantize
  root_element ||= resource_name.to_s.pluralize
  
  it "calls #all on the resource class (#{resource_class.name})" do
    resource_class.should_receive(:all)
    action
  end
  it "returns HTTP status 200 (OK)" do
    expect(action.status).to eq 200
  end
  it "returned json contains the correct root element (#{root_element})" do
    expect(action.body).to have_json_path(root_element)
  end
  context "when resources do NOT exist" do
    it "returned json contains no records" do
      expect(action.body).to have_json_size(0).at_path(root_element)
    end
  end
  context "when resources DO exist" do
    let!(:resource_list) { FactoryGirl.create_list resource_name, 3 }
    it "returned json contains the correct number of records" do
      expect(action.body).to have_json_size(resource_list.length).at_path(root_element)
    end
  end
end
  