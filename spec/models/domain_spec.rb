require 'spec_helper'

describe Domain do
  let(:domain) { FactoryGirl.build :domain }
  
  # factory
  it { should have_a_valid_factory }
  
  # associations
  it { should belong_to(:organization) }
 
  # validations
  # - name
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).case_insensitive }
  # - organization
  it { should validate_existence_of(:organization) }
  
  # indexes
  it { should have_db_index(:name).unique(true) }
  
  # callback: before_save
  describe "#before_save" do
    it "downcases name" do
      domain2 = FactoryGirl.create :domain, name: domain.name.upcase
      expect(domain2.name).to eq domain.name
    end
  end
  

end