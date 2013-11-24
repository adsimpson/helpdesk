require 'spec_helper'

describe EmailAddress do
  let(:resource) { FactoryGirl.build :email_address }

  # factory
  it { should have_a_valid_factory }
  
  # associations
  it { should belong_to :user  }

  # validations
  # - user
  it { should validate_existence_of :user }
  # - address
  it { should validate_presence_of(:value) }
  it do
    resource.save  # hack to ensure record is saved before uniqueness test with new record
    should validate_uniqueness_of(:value).case_insensitive
  end
  it { should allow_value("user@foo.COM", "A_US-ER@f.b.org", "frst.lst@foo.jp", "a+b@baz.cn").for(:value) }
  it { should_not allow_value("user@foo,com", "user_at_foo.org", "example.user@foo.", "foo@bar_baz.com", "foo@bar+baz.com").for(:value) }

  # indexes
  it { should have_db_index(:value).unique(true) }
  it { should have_db_index(:user_id) }
  
  # class method: new
  describe ".new" do
    subject { resource }
    it { should be_valid }
    its(:verified) { should be_false }
    its(:primary) { should be_false }
  end
    
  # callback: before save
  describe "#before_save" do
    it "downcases address" do
      resource_2 = FactoryGirl.create :email_address, value: resource.value.upcase
      expect(resource_2.value).to eq resource.value
    end
  end

  # callback: before_create
  describe "#before_create" do
    let(:user) { resource.user }
    context "when user does not have any existing email addresses" do
      before { user.email_addresses.delete_all }
      it "sets primary = true" do
        resource.save
        expect(resource.primary).to be_true
      end
    end
    context "when user does have existing email addresses" do
      before { FactoryGirl.create :email_address, user: user }
      it "does not set primary = true" do
        resource.save
        expect(resource.primary).to be_false
      end
    end
  end

  # callback: after_save
  describe "#after_save" do
    let(:user) { resource.user }
    context "when user already has a primary email address" do
      context "and primary == true" do
        it "sets 'primary' on the previous primary email address to false" do
          primary_resource = FactoryGirl.create :email_address, user: user, primary: true
          resource.update_attributes(primary: true)
          expect(primary_resource.reload.primary).to be_false
        end
      end
      context "and primary == false" do
        it "does not update 'primary' on the previous primary email address" do
          primary_resource = FactoryGirl.create :email_address, user: user, primary: true
          resource.update_attributes(primary: false)
          expect(primary_resource.reload.primary).to be_true
        end
      end
    end
    context "when verified == true" do
      it "deletes any email verification tokens associated with the email address" do
        resource.save
        tokens = FactoryGirl.create_list :email_verification_token, 3, email_address: resource
        resource.update_attributes(verified: true)
        expect(EmailVerificationToken.where(email_address: resource).count).to eq 0
      end
    end
  end

    
  # callback: before_destroy
  describe "#before_destroy" do
    it "does not allow deletion if primary == true" do
      resource.update_attributes(primary: true)
      resource.destroy
      expect(resource.destroy).to be_false
    end
  end

end