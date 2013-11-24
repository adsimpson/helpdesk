require 'spec_helper'

describe EmailVerificationService do
  let(:user) { FactoryGirl.create :user }
  let(:email_address) { user.primary_email_address }
  let(:service) { EmailVerificationService.new email_address } 
  
  # CLASS METHOD: active? 
  describe ".active?" do
    subject { EmailVerificationService.active? }
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
    before { service.send_instructions }
    it "generates & stores a new email verification token" do
      expect(EmailVerificationToken.last.email_address).to eq email_address
    end
    it "sets a verification expiry timestamp" do
      expect(EmailVerificationToken.last.expires_at).to be > Time.now.utc
    end
    it "sends verification instructions to the email address" do
      expect(ActionMailer::Base.deliveries.last.to).to eq [email_address.value]
    end
  end
  
  # METHOD: can_verify? 
  describe "#can_verify?" do
    subject { service.can_verify? }
    context "when email_address is NIL" do
      before { email_address = nil }
      it { should be_false }
    end
    context "when instructions have NOT been sent" do
      it { should be_false }
    end
    context "when instructions have been sent" do
      before { service.send_instructions }
      context "and have since expired" do
        before { Timecop.freeze(service.token.expires_at + 1.minute) }
        after { Timecop.return }
        it { should be_false }
      end
      context "and have NOT expired" do
        before { Timecop.freeze(service.token.expires_at - 1.minute) }
        after { Timecop.return }
        it { should be_true }
      end
    end
  end

  # METHOD: verify 
  describe "#verify" do
    before { service.send_instructions }
    let(:password) { User.random_password.downcase } 
    context "with a valid / matching password & password confirmation" do
      let(:password_confirmation) { password }
      let!(:result) { service.verify(password, password_confirmation) }
      it "returns true" do
        expect(result).to be_true
      end
      it "updates the email address' verified status" do
        found_email_address = EmailAddress.find(email_address.id)
        expect(found_email_address.verified).to be_true
      end
      it "updates the user's verified status" do
        found_user = User.find(user.id)
        expect(found_user.verified).to be_true
      end
      it "updates the user's password" do
        found_user = User.find(user.id)
        expect(found_user.password_digest).to_not eq user.password_digest
      end
      it "deletes the email verification token" do
        found_token = EmailVerificationToken.where(id: service.token.id).first
        expect(found_token).to be_nil
      end
      it "sends verification success message to the user's email address" do
        expect(ActionMailer::Base.deliveries.last.to).to eq [email_address.value]
      end
    end
    context "with a non-matching password & password confirmation" do
      let(:password_confirmation) { password.upcase }
      let!(:result) { service.verify(password, password_confirmation) }
      it "returns false" do
        expect(result).to be_false
      end
      it "doesn't update the email address' verified status" do
        found_email_address = EmailAddress.find(email_address.id)
        expect(found_email_address.verified).to be_false
      end
      it "doesn't update the user's verified status" do
        found_user = User.find(user.id)
        expect(found_user.verified).to be_false
      end
      it "doesn't update the user's password" do
        found_user = User.find(user.id)
        expect(found_user.password_digest).to eq user.password_digest
      end
      it "doesn't delete the email verification token" do
        found_token = EmailVerificationToken.where(id: service.token.id).first
        expect(found_token).not_to be_nil
      end

    end
  end

end