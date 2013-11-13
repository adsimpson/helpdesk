require 'spec_helper'

describe GroupMembership do
  let(:user) { FactoryGirl.create :user, role: "agent" }
  let(:group) { FactoryGirl.create :group }
  let(:group_membership) { FactoryGirl.build :group_membership, user: user, group: group }
  
  # associations
  it { should belong_to(:user) }
  it { should belong_to(:group) }
  
  # validations
  # - group
  it { should validate_existence_of(:group) }
  # - user
  it { should validate_existence_of(:user) }
  describe "#user_validator" do
    ["agent", "admin"].each do |valid_role|
      it "should allow user role '#{valid_role}'" do
        user.role = valid_role
        expect(group_membership).to be_valid
      end
    end
    ["end_user"].each do |invalid_role|
      it "should not allow user role '#{invalid_role}'" do
        user.role = invalid_role
        expect(group_membership).to be_invalid
      end
    end
  end
  
  # indexes
  it { should have_db_index([:user_id, :group_id]).unique(true) }
  it { should have_db_index([:group_id,:user_id]).unique(true) }
  
  # method: new
  describe ".new" do
    subject { group_membership }
    it { should be_valid }
    its(:default) { should be_false }
  end
  
  # callback: before create
  describe ".before_create" do
    context "if user is not a member of another group" do
      before { GroupMembership.where(user: user).delete_all }
      it "should set default = true" do
        group_membership.save
        expect(group_membership.default).to eq true
      end
    end
    context "if user is already a member of another group" do
      before { FactoryGirl.create :group_membership, user: user }
      it "should set default = false" do
        group_membership.save
        expect(group_membership.default).to eq false
      end
    end
  end


end