require 'spec_helper'

describe TicketComment do
  let(:comment) { FactoryGirl.build :ticket_comment }
  
  # factory
  it { should have_a_valid_factory }
  
  # associations
  it { should belong_to(:ticket) }
  it { should belong_to(:author) }
  
  # validations
  it { should validate_presence_of(:body) }
  it { should validate_existence_of(:ticket) }
  it { should validate_existence_of(:author) }

  # indexes
  it { should have_db_index(:ticket_id) }
  it { should have_db_index(:author_id) }
  
  # method: new
  describe ".new" do
    subject { comment }
    it { should be_valid }
    its(:public) { should be_true }
  end
  
  # method: save
  describe "#save" do
    context "on update" do
      before { comment.save }
      it "does NOT persist changes to the 'body' attribute" do
        expect { comment.update_attributes(body: "updated...") }.to_not change { comment.reload.body }
      end
      it "does NOT persist changes to the 'ticket' attribute" do
        ticket = FactoryGirl.create :ticket
        expect { comment.update_attributes(ticket: ticket) }.to_not change { comment.reload.ticket }
      end
      it "does NOT persist changes to the 'author' attribute" do
        author = FactoryGirl.create :user
        expect { comment.update_attributes(author: author) }.to_not change { comment.reload.author }
      end
    end
  end
end