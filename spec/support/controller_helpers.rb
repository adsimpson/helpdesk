module ControllerHelpers
  
  def stub_authentication
    controller.stub :current_user => FactoryGirl.build_stubbed(:user, role: "admin")
    controller.stub(:signed_in?).and_return(true) 
  end
  
  def stub_authorization
    stub_authentication
    controller.stub(:authorize_user!).and_return(true) 
    controller.stub(:authorize).and_return(true) 
    controller.stub(:verify_authorized)
  end
  
  def sign_in(user = double("user"))
    controller.stub :current_user => user
    controller.stub :user_access_service => UserAccessService.new(user)
  end
  
  def no_sign_in
    sign_in nil
  end
  
  def verified_user(attributes = {})
    attributes[:verified] = true
    FactoryGirl.build_stubbed :user, attributes
  end
  
  def sign_in_as(role=nil)
    user = role.nil? ? nil : verified_user(role: role.to_s)
    sign_in(user)
  end
  
  def json
    @json ||= response.body
  end

  def resource_class
    described_class.controller_name.classify.constantize
  end

  def resource
    resource_class.last
  end

end

RSpec.configure do |config|
  config.include ControllerHelpers, :type => :controller
end