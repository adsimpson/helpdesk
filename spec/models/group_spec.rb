require 'spec_helper'

describe Group do
  let(:group) { FactoryGirl.build :group }
  
  # factory
  it { should have_a_valid_factory }
  
  # associations
  it { should have_many(:group_memberships).dependent(:destroy) }
  it { should have_many(:users).through(:group_memberships) }
  
  # validations
  # - name
  it { should validate_presence_of(:name) }
  it { should ensure_length_of(:name).is_at_most(50) }
  it { should validate_uniqueness_of(:name).case_insensitive }
 
  # indexes 
  it { should have_db_index(:name).unique(true) }

end