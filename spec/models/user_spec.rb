require 'spec_helper'

describe User do
  
  # CHECK FACTORY
  it "has a valid factory" do
    expect(FactoryGirl.build(:user)).to be_valid
  end
  
  before :all do
    @user = FactoryGirl.build(:user)
  end
  
  # subject { @user }
  
  # CHECK DEFAULT ATTRIBUTE VALUES ON INITIALIZATION
  context "when initialized" do
    
    describe "role should equal 'end_user'" do
      expect(@user.role).to eq "end_user"
    end
    
  end

  # CHECK VALIDATIONS - PRESENCE
  
  describe "is invalid when name is not present" do
    before { @user.name = " " }
    expect(@user).to_not be_valid
  end

  describe "is invalid when email is not present" do
    before { @user.email = " " }
    expect(@user).to_not be_valid
  end  
  
  
end