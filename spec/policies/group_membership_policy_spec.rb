require 'spec_helper'

describe GroupMembershipPolicy do
  subject { GroupMembershipPolicy.new current_user, group_membership }

  let(:user) { FactoryGirl.create :user, role: "agent" }
  let(:group) { FactoryGirl.create :group }
  let(:group_membership) { FactoryGirl.create :group_membership, user: user, group: group }
  
  context "for an administrator" do
    let(:current_user) { FactoryGirl.create :user, role: "admin" }
    it { should permit :index   }
    it { should permit :show    }
    it { should permit :create  }
    it { should permit :update  }
    it { should permit :destroy }
  end

  context "for an agent" do
    let(:current_user) { FactoryGirl.create :user, role: "agent" }
    it { should permit :index       }
    it { should permit :show        }
    it { should_not permit :create  }
    it { should_not permit :update  }
    it { should_not permit :destroy }
  end

  context "for an end_user" do
    let(:current_user) { FactoryGirl.create :user, role: "end_user" }
    it { should_not permit :index   }
    it { should_not permit :show    }
    it { should_not permit :create  }
    it { should_not permit :update  }
    it { should_not permit :destroy }
  end
end
