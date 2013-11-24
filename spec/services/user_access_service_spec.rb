require 'spec_helper'

describe UserAccessService do
  let(:user) { FactoryGirl.create :user }
  let(:email_address) { user.primary_email_address }
  let(:service) { UserAccessService.new email_address } 
  
  # METHOD: authenticate 
  describe "#authenticate" do
    subject { service.authenticate password }
    context "when password is correct" do
      let(:password) { user.password }
      it { should be_true }      
    end
    context "when password is incorrect" do
      let(:password) { user.password.upcase }
      it { should be_false }      
    end
  end

  # METHOD: sign_in 
  describe "#sign_in" do
    it "generates & stores a new access token for the user" do
      service.sign_in
      expect(AccessToken.last.email_address).to eq email_address
    end
    context "when user signs in for the first time" do
      before { service.sign_in }
      it "sets user 'sign_in_count' to 1" do
        expect(user.reload.sign_in_count).to eq 1
      end
      it "sets 'previous_sign_in_at' and 'latest_sign_in_at' to the same value" do
        expect(user.reload.previous_sign_in_at.to_s).to eq user.reload.latest_sign_in_at.to_s
      end
    end
    context "when user has previously signed-in" do
      before { 1.upto(2) { service.sign_in } }
      it "increments 'sign_in_count' by 1" do
        expect{ service.sign_in }.to change{ user.reload.sign_in_count }.by(1)
      end
      it "sets 'previous_sign_in_at' equal to the old 'latest_sign_in_at'" do
        old_latest = user.reload.latest_sign_in_at
        service.sign_in
        expect(user.reload.previous_sign_in_at.to_s).to eq old_latest.to_s
      end    
      it "updates 'latest_sign_in_at' to a more recent timestamp" do
        expect(user.reload.latest_sign_in_at).to be >= user.reload.previous_sign_in_at
      end    
    end
  end
  
  # METHOD: sign_out 
  describe "#sign_out" do
    before { service.sign_in }
    it "deletes the access token" do
      service.sign_out
      found_access_token = AccessToken.where(id: service.token.id).first
      expect(found_access_token).to be_nil
    end
  end
  
end
