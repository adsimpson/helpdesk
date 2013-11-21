require 'spec_helper'

describe PasswordResetService do
  let(:user) { FactoryGirl.create :user }
  let(:service) { PasswordResetService.new user } 
  
  # CLASS METHOD: active? 
  describe ".active?" do
    subject { PasswordResetService.active? }
    context "when password reset workflow is enabled within tenant configuration" do
      # TODO
      # it { should be_true }
      it "should be true"
    end
    context "when password reset workflow is disabled within tenant configuration" do
      # TODO
      # it { should be_false }
      it "should be false"
    end
  end
  
  # METHOD: send_instructions 
  describe "#send_instructions" do
    before { service.send_instructions }
    it "generates & stores a new password reset token" do
      expect(PasswordResetToken.last.user).to eq user
    end
    it "sets a password reset expiry timestamp" do
      expect(PasswordResetToken.last.expires_at).to be > Time.now.utc
    end
    it "sends password reset instructions to the user's email address" do
      expect(ActionMailer::Base.deliveries.last.to).to eq [user.email]
    end
  end
  
  # METHOD: can_reset 
  describe "#can_reset?" do
    subject { service.can_reset? }
    context "when user is NIL" do
      before { user = nil }
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

  # METHOD: reset 
  describe "#reset" do
    before { service.send_instructions }
    let(:password) { User.random_password.downcase } 
    let(:password_confirmation) { password }
    context "with a valid / matching password & password confirmation" do
      let!(:result) { service.reset(password, password_confirmation) }
      it "returns true" do
        expect(result).to eq true
      end
      it "updates the user's password" do
        found_user = User.find(user.id)
        expect(found_user.authenticate(password)).to eq user
      end
      it "deletes the password reset token" do
        found_token = PasswordResetToken.where(id: service.token.id).first
        expect(found_token).to be_nil
      end
      it "sends password reset success message to the user's email address" do
        expect(ActionMailer::Base.deliveries.last.to).to eq [user.email]
      end
    end
    
    context "with a blank password" do
      let(:password) { " " }
      let!(:result) { service.reset(password, password_confirmation) }
      it "returns false" do
        expect(result).to eq false
      end
      it "doesn't update the user's password" do
        found_user = User.find(user.id)
        expect(found_user.authenticate(password)).to be_false
      end
      it "doesn't delete the password reset token" do
        found_token = PasswordResetToken.where(id: service.token.id).first
        expect(found_token).not_to be_nil
      end
    end
    
    context "with a non-matching password & password confirmation" do
      let(:password_confirmation) { password.upcase }
      let!(:result) { service.reset(password, password_confirmation) }
      it "returns false" do
        expect(result).to eq false
      end
      it "doesn't update the user's password" do
        found_user = User.find(user.id)
        expect(found_user.authenticate(password)).to be_false
      end
      it "doesn't delete the password reset token" do
        found_token = PasswordResetToken.where(id: service.token.id).first
        expect(found_token).not_to be_nil
      end
    end
  end

end