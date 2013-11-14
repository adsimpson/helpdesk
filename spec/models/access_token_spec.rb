require 'spec_helper'

describe AccessToken do
  let(:expires_at) { nil }
  let(:access_token) { FactoryGirl.build :access_token, expires_at: expires_at }
  
  # factory
  it { should have_a_valid_factory }
  
  # associations
  it { should belong_to(:user) }
 
  # indexes
  it { should have_db_index(:token_digest).unique(true) }
  it { should have_db_index(:user_id).unique(false) }
  
  # callback: before_create
  describe "#before_create" do
    before { access_token.save }
    it "generates token" do
      expect(access_token.token).to_not be_nil
    end
    it "generates token_digest" do
      expect(access_token.token_digest).to_not be_nil
    end
  end
  
  # attribute: token
  describe "token" do
    before { access_token.save }
    it "is NOT persisted to the database" do
      expect(AccessToken.last.token).to be_nil
    end
  end    
  
  # attribute: token
  describe "token_digest" do
    before { access_token.save }
    it "is persisted to the database" do
      expect(AccessToken.last.token_digest).to_not be_nil
    end
  end    
  
  # method: expired?
  describe "#expired?" do
    subject { access_token.expired? }
    context "when 'expires_at' has NOT been set" do
      it { should be_false }
    end
    context "when 'expires_at' has been set" do
      let(:expires_at) { 1.day.from_now }
      context "to before current date / time" do
        before { Timecop.freeze(access_token.expires_at + 1.minute) }
        after { Timecop.return }
        it { should be_true }
      end
      context "to after current date / time" do
        before { Timecop.freeze(access_token.expires_at - 1.minute) }
        after { Timecop.return }
        it { should be_false }
      end
    end
  end

end