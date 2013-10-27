require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.build :user }
  
  it "has a valid factory" do 
    expect(user).to be_valid 
  end 
  
  # ATTRIBUTE: name 
  describe "name" do
    it "cannot be nil" do
      user.name = nil
      expect(user).to be_invalid 
    end
    it "cannot be blank" do
      user.name = "    "
      expect(user).to be_invalid 
    end
    it "cannot be more than 50 chars" do
      user.name = "a" * 51
      expect(user).to be_invalid 
    end
    it "can be less than or equal to 50 chars" do
      user.name = "a" * 50
      expect(user).to be_valid 
    end
  end
  
  # ATTRIBUTE: email 
  describe "email" do
    it "cannot be nil" do
      user.email = nil
      expect(user).to be_invalid 
    end
    it "cannot be blank" do
      user.email = "    "
      expect(user).to be_invalid 
    end
    it "cannot have an invalid format" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        user.email = invalid_address
        expect(user).to be_invalid
      end
    end
    it "can have a valid format" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        user.email = valid_address
        expect(user).to be_valid
      end
    end
    it "must be unique" do
      older_user = FactoryGirl.create :user
      user.email = older_user.email.upcase
      expect(user).to be_invalid
    end
    it "is saved as lowercase" do
      mixed_case_email = "Foo@ExAMPle.CoM"
      user.email = mixed_case_email
      user.save
      expect(user.reload.email).to eq mixed_case_email.downcase    
    end
    
  end
  
  # ATTRIBUTE: role 
  describe "role" do
    it "defaults to 'end_user'" do
      expect(user.role).to eq "end_user"
    end
    it "cannot be nil" do
      user.role = nil
      expect(user).to be_invalid 
    end
    it "cannot be blank" do
      user.role = "    "
      expect(user).to be_invalid 
    end
    it "must be one of 'admin', 'agent' or 'end_user'" do
      roles = ["admin", "agent", "end_user"]
      roles.each do |valid_role|
        user.role = valid_role
        expect(user).to be_valid
      end
    end
    it "cannot be anything other than 'admin', 'agent' or 'end_user'" do
      roles = ["Admin", "agent ", "end user"]
      roles.each do |invalid_role|
        user.role = invalid_role
        expect(user).to be_invalid
      end
    end
  end
  
  # ATTRIBUTE: Password 
  describe "password" do
    it "cannot be nil" do
      user.password = user.password_confirmation = nil
      expect(user).to be_invalid 
    end
    it "cannot be less than 6 characters" do
      user.password = user.password_confirmation = "a" * 5
      expect(user).to be_invalid 
    end
    it "can be 6 characters or more" do
      user.password = user.password_confirmation = "a" * 6
      expect(user).to be_valid 
    end
    it "must match 'password_confirmation'" do
      user.password_confirmation = "a" * 6
      expect(user).to be_invalid 
    end
    describe "auto-generation" do
      it "occurs on create if both password & confirmation are nil" do
        user.password = user.password_confirmation = nil
        user.save
        expect(user.password_digest).not_to be_nil
      end
      it "does not occur on create if both password & confirmation are non-nil" do
        user.password = user.password_confirmation = "a" * 6
        user.save
        expect(user.authenticate("a" * 6)).to eq user
      end
      it "only occurs on create if both password & confirmation are nil" do
        user.save
        user.password = user.password_confirmation = nil
        user.save
        expect(user).to be_invalid
      end
    end
  end
  
end