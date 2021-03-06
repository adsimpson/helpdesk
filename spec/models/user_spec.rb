require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.build :user }
  
  # factory
  it { should have_a_valid_factory }
  
  # associations
  it { should belong_to(:organization) }
  it { should have_many(:email_addresses).dependent(:delete_all) }
  it { should accept_nested_attributes_for(:email_addresses).allow_destroy(true) }
  
  # validations
  # - name
  it { should validate_presence_of(:name) }
  it { should ensure_length_of(:name).is_at_most(50) }
  
  # - role
  it { should ensure_inclusion_of(:role).in_array(["admin", "agent", "end_user"]) }
  
  # - email
  describe "#email_addresses_validator" do
    before { user.email_addresses.delete_all }
    it "ensures at least one email address is defined" do
      expect(user).to be_invalid
    end
  end

  # it { should validate_presence_of(:email) }
  # it do
  #  user.save  # hack to ensure record is saved with valid password_digest before uniqueness test with new record
  #  should validate_uniqueness_of(:email).case_insensitive
  #end
  #it { should allow_value("user@foo.COM", "A_US-ER@f.b.org", "frst.lst@foo.jp", "a+b@baz.cn").for(:email) }
  # it { should_not allow_value("user@foo,com", "user_at_foo.org", "example.user@foo.", "foo@bar_baz.com", "foo@bar+baz.com").for(:email) }
  
  # - password
  it { should have_secure_password }
  it { should ensure_length_of(:password).is_at_least(6) }
  it { should validate_confirmation_of(:password) }
    
  # - organization
  it { should validate_existence_of(:organization) }
  describe "#organization_validator" do
    let(:organization) { FactoryGirl.create :organization }
    before { user.organization = organization }
    ["agent", "end_user"].each do |valid_role|
      it "allows user role '#{valid_role}'" do
        user.role = valid_role
        expect(user).to be_valid
      end
    end
    ["admin"].each do |invalid_role|
      it "doesn't allow user role '#{invalid_role}'" do
        user.role = invalid_role
        expect(user).to be_invalid
      end
    end
  end
    
  # indexes
  it { should have_db_index(:organization_id) }

  # method: new
  describe ".new" do
    subject { user }
    it { should be_valid }
    its(:active) { should be_true }
    # its(:verified) { should be_false }
    its(:role) { should eq "end_user" }
  end

  # callback: before validation
  describe "#before_validation" do
    context "if both password & password_confirmation are nil" do
      before { user.assign_attributes(password: nil, password_confirmation: nil) }
      it "auto-generates password" do
        user.valid?
        expect(user.password).not_to be_nil
      end
    end
    context "if either password or password_confirmation are present" do
      let(:password) { User.random_password }
      before { user.assign_attributes(password: password, password_confirmation: password) }
      it "doesn't auto-generate password" do
        user.valid?
        expect(user.password).to eq password
      end
    end
  end
    
  # callback: after save
  describe "#after_save" do
    context "if role is changed to 'end_user' when group_memberships exist" do
      before do
        user.update_attributes(role: "agent")
        1.upto(3) { FactoryGirl.create :group_membership, user: user }
        user.update_attributes(role: "end_user")
      end
      it "auto-deletes all associated group_memberships" do
        expect(user.group_memberships.count).to eq 0
      end
    end
    context "if role == 'end_user' and no organization is assigned" do
      let(:organization) { FactoryGirl.create :organization_with_domains }
      let(:email_address) { user.email_addresses.first } 
      before { user.assign_attributes(role: "end_user", organization: nil) }
      it "auto-assigns organization based on email domain" do
        email_address.value = "user@#{organization.domains.first.name}"
        user.save
        expect(user.organization).to eq organization
      end
    end
  end


end