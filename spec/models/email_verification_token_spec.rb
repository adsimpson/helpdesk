require 'spec_helper'

describe EmailVerificationToken do
  let(:token) { FactoryGirl.build :email_verification_token }
  
  # factory
  it { should have_a_valid_factory }
  
  # associations
  it { should belong_to(:email_address) }
 
  # indexes
  it { should have_db_index(:token_digest).unique(true) }
  it { should have_db_index(:email_address_id).unique(false) }
  
  # callback: before_create
  describe "#before_create" do
    before { token.save }
    it "generates token" do
      expect(token.token).to_not be_nil
    end
    it "generates token_digest" do
      expect(token.token_digest).to_not be_nil
    end
  end
  
  # attribute: token
  describe "token" do
    before { token.save }
    it "is NOT persisted to the database" do
      expect(EmailVerificationToken.last.token).to be_nil
    end
  end    
  
  # attribute: token
  describe "token_digest" do
    before { token.save }
    it "is persisted to the database" do
      expect(EmailVerificationToken.last.token_digest).to_not be_nil
    end
  end    
  
  # method: expired?
  describe "#expired?" do
    subject { token.expired? }
    context "when 'expires_at' has NOT been set" do
      before { token.expires_at = nil }
      it { should be_false }
    end
    context "when 'expires_at' has been set" do
      context "to before current date / time" do
        before { Timecop.freeze(token.expires_at + 1.minute) }
        after { Timecop.return }
        it { should be_true }
      end
      context "to after current date / time" do
        before { Timecop.freeze(token.expires_at - 1.minute) }
        after { Timecop.return }
        it { should be_false }
      end
    end
  end

end