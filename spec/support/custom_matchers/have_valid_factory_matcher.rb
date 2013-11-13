RSpec::Matchers.define :have_a_valid_factory do
  match do |subject|
    factory = subject.class.name.underscore.to_sym
    expect(FactoryGirl.build(factory)).to be_valid
  end
    
end