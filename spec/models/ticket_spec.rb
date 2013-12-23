require 'spec_helper'

describe Ticket do
  let(:ticket) { FactoryGirl.build :ticket }
  
  # factory
  it { should have_a_valid_factory }
  
  # associations
  it { should belong_to(:requester) }
  it { should belong_to(:submitter) }
  it { should belong_to(:assignee) }
  it { should belong_to(:group) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should accept_nested_attributes_for(:comments) }

  # validations
  it { should validate_presence_of(:description) }
  it { should ensure_inclusion_of(:ticket_type).in_array(["problem", "incident", "question", "task"]) }
  it { should ensure_inclusion_of(:status).in_array(["new", "open", "pending", "hold", "solved", "closed"]) }
  it { should ensure_inclusion_of(:priority).in_array(["urgent", "high", "normal", "low"]) }

  it { should validate_existence_of(:requester) }
  it { should validate_existence_of(:submitter) }
  it { should validate_existence_of(:assignee) }
  describe "#assignee_validator" do
    ["agent", "admin"].each do |valid_role|
      it "allows user role '#{valid_role}'" do
        ticket.assignee.role = valid_role
        expect(ticket).to be_valid
      end
    end
    ["end_user"].each do |invalid_role|
      it "does not allow user role '#{invalid_role}'" do
        ticket.assignee.role = invalid_role
        expect(ticket).to be_invalid
      end
    end
    it "allows assignee to be nil" do
      ticket.assignee = nil
      expect(ticket).to be_valid
    end
    it "allows assignee to be a member of the group the ticket is assigned to" do
      group_membership = FactoryGirl.create :group_membership, user: ticket.assignee
      ticket.group = group_membership.group
      expect(ticket).to be_valid
    end
    it "raises an error if assignee is NOT a member of the group the ticket is assigned to" do
      ticket.group = FactoryGirl.create :group
      expect(ticket).to be_invalid
    end
  end
  it { should validate_existence_of(:group) }
  
  # indexes
  it { should have_db_index(:requester_id) }
  it { should have_db_index(:submitter_id) }
  it { should have_db_index(:assignee_id) }
  it { should have_db_index(:group_id) }

  # method: new
  describe ".new" do
    subject { ticket }
    it { should be_valid }
    its(:status) { should eq "new" }
    its(:priority) { should eq "normal" }
  end
  
  # callback: before validation
  describe "#before_validation" do
    context "if no submitter is assigned" do
      before { ticket.submitter = nil }
      it "auto-assigns requester as submitter" do
        expect { ticket.valid? }.to change { ticket.submitter }.to(ticket.requester)
      end
    end
    it "auto-assigns submitter as the first comment author" do
      ticket.submitter = FactoryGirl.create :user
      expect { ticket.valid? }.to change { ticket.comments.first.author }.to(ticket.submitter)
    end
    context "if assignee is defined but no group is assigned to the ticket" do
      it "auto-assigns the ticket's group as per the assignee's default group membership" do
        group_membership = FactoryGirl.create :group_membership, user: ticket.assignee
        expect { ticket.valid? }.to change { ticket.group }.to(group_membership.group)
      end
    end
  end
  
  # callback: before save
  describe "#before_save" do
    let(:requester) { ticket.requester }
    let(:user_tags) { ["a","b","c"] }
    let(:org_tags) { ["d","e","f"] }
    let(:combined_tags) { user_tags + org_tags }
    before do
      organization = FactoryGirl.create :organization, tag_list: org_tags
      requester.update_attributes(tag_list: user_tags, organization: organization)
    end
    context "on create" do
      it "auto-assigns the requester's (plus their linked organization's) tags to the ticket" do
        expect { ticket.save }.to change { ticket.tag_list }.to(combined_tags)
      end
    end
    context "on update (when requester is changed)" do
      before { ticket.save }
      it "removes the previous requester's (plus their linked organization's) tags from the ticket" do
        ticket.update_attributes(requester: FactoryGirl.create(:user))
        expect(ticket.reload.tag_list.count).to eq 0
      end
      it "auto-assigns the new requester's (plus their linked organization's) tags to the ticket" do
        new_organization = FactoryGirl.create(:organization, tag_list: ["org_1","org_2","org_3"])
        new_requester = FactoryGirl.create(:user, organization: new_organization, tag_list: ["req_1","req_2","req_3"])
        new_tags = new_requester.tag_list + new_organization.tag_list
        new_tags.uniq!
        ticket.update_attributes(requester: new_requester)
        expect(ticket.reload.tag_list).to eq new_tags
      end
    end
    
  end
  
end
