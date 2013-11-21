require 'spec_helper'

describe GroupMembership do
  let(:user) { FactoryGirl.create :user, role: "agent" }
  let(:group) { FactoryGirl.create :group }
  let(:group_membership) { FactoryGirl.build :group_membership, user: user, group: group }
  
  # factory
  it { should have_a_valid_factory }
  
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
      it "allows user role '#{valid_role}'" do
        user.role = valid_role
        expect(group_membership).to be_valid
      end
    end
    ["end_user"].each do |invalid_role|
      it "does not allow user role '#{invalid_role}'" do
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
  describe "#before_create" do
    context "when user is not a member of another group" do
      before { GroupMembership.where(user: user).delete_all }
      it "sets default = true" do
        group_membership.save
        expect(group_membership.default).to eq true
      end
    end
    context "when user is already a member of another group" do
      before { FactoryGirl.create :group_membership, user: user }
      it "sets default = false" do
        group_membership.save
        expect(group_membership.default).to eq false
      end
    end
  end

  # callback: after_save
  describe "#after_save" do
    context "when user already has a default group membership" do
      context "and default == true" do
        it "sets 'default' on the previous default membership to false" do
          default_group_membership = FactoryGirl.create :group_membership, user: user, default: true
          group_membership.update_attributes(default: true)
          expect(default_group_membership.reload.default).to eq false
        end
      end
      context "and default == false" do
        it "does not update 'default' on the previous default membership" do
          default_group_membership = FactoryGirl.create :group_membership, user: user, default: true
          group_membership.update_attributes(default: false)
          expect(default_group_membership.reload.default).to eq true
        end
      end
    end
  end

end