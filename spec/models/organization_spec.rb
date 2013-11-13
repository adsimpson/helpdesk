require 'spec_helper'

describe Organization do
  let(:organization) { FactoryGirl.build :organization }
  
  # factory
  it { should have_a_valid_factory }
  
  # associations
  it { should belong_to(:group) }
  it { should have_many(:users).dependent(:nullify) }
  it { should have_many(:domains).dependent(:destroy) }
  it { should accept_nested_attributes_for(:domains).allow_destroy(true) }

  # validations
  # - name
  it { should validate_presence_of(:name) }
  it { should ensure_length_of(:name).is_at_most(50) }
  it { should validate_uniqueness_of(:name).case_insensitive }
  # - group
  it { should validate_existence_of(:group) }
  
  # indexes
  it { should have_db_index(:name).unique(true) }

 
end