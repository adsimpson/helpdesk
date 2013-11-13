require 'spec_helper'

describe EmailVerification do
  let(:user) { FactoryGirl.create :user }
  let(:email_verification) { EmailVerification.new user } 
  
  # CLASS METHOD: service_active? 
  describe ".service_active?" do
    subject { EmailVerification.service_active? }
    context "when email verification workflow is enabled within tenant configuration" do
      # TODO
      # it { should be_true }
      it "should be true"
    end
    context "when email verification workflow is disabled within tenant configuration" do
      # TODO
      # it { should be_false }
      it "should be false"
     end
  end

  # METHOD: send_instructions 
  describe "#send_instructions" do
    before { email_verification.send_instructions }
    it "generates & stores a new verification token" do
      expect(user.reload.verification_token).not_to be_nil
    end
    it "sets a verification expiry timestamp" do
      expect(user.reload.verification_token_expires_at).to be > Time.now.utc
    end
    it "sends verification instructions to the user's email address" do
      expect(ActionMailer::Base.deliveries.last.to).to eq [user.email]
    end
  end
  
  # METHOD: token_exists?
  describe "#token_exists?" do
    subject { email_verification.token_exists? }
    context "when instructions have NOT been sent" do
      it { should be_false }
    end
    context "when instructions have been sent" do
      before { email_verification.send_instructions }
      it { should be_true }
    end
  end

  # METHOD: token_expired?
  describe "#token_expired?" do
    subject { email_verification.token_expired? }
    context "when instructions have NOT been sent" do
      it { should be_nil }
    end
    context "when instructions have been sent" do
      before { email_verification.send_instructions } 
      context "and have since expired" do
        before { user.verification_token_expires_at = 1.hour.ago }
        it { should be_true }
      end
      context "and have NOT expired" do
        it { should be_false }
      end
    end
  end

  # METHOD: can_update 
  describe "#can_update?" do
    subject { email_verification.can_update? }
    context "when user is NIL" do
      before { user = nil }
      it { should be_false }
    end
    context "when instructions have NOT been sent" do
      it { should be_false }
    end
    context "when instructions have been sent" do
      before { email_verification.send_instructions }
      context "and have since expired" do
        before { user.verification_token_expires_at = 1.hour.ago }
        it { should be_false }
      end
      context "and have NOT expired" do
        it { should be_true }
      end
    end
  end

  # METHOD: update 
  describe "#update" do
    before { email_verification.send_instructions }
    let(:password) { User.random_password.downcase } 
    context "with a valid / matching password & password confirmation" do
      let(:password_confirmation) { password }
      let!(:result) { email_verification.update(password, password_confirmation) }
      it "returns true" do
        expect(result).to eq true
      end
      it "deletes the verification token" do
        expect(user.reload.verification_token).to be_nil
      end
      it "deletes the verification expiry timestamp" do
        expect(user.reload.verification_token_expires_at).to be_nil
      end
      it "sets verified = true" do
        expect(user.reload.verified).to eq true
      end
      it "sends verification success message to the user's email address" do
        expect(ActionMailer::Base.deliveries.last.to).to eq [user.email]
      end
    end
    context "with a non-matching password & password confirmation" do
      let(:password_confirmation) { password.upcase }
      let!(:result) { email_verification.update(password, password_confirmation) }
      it "returns false" do
        expect(result).to eq false
      end
      it "retains the verification token" do
        expect(user.reload.verification_token).not_to be_nil
      end
      it "retains the verification expiry timestamp" do
        expect(user.reload.verification_token_expires_at).not_to be_nil
      end
      it "retains verified = false" do
        expect(user.reload.verified).to eq false
      end
    end
  end

end