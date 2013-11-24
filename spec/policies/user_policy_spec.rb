require 'spec_helper'

describe UserPolicy do
  let(:policy) { UserPolicy.new current_user, user }
  subject { policy }

  context "for an administrator" do
    let(:current_user) { FactoryGirl.create :user, role: "admin" }
    let(:user) { User }
    it { should permit :index   }
    context "when record == end_user" do 
      let(:user) { FactoryGirl.create :user, role: "end_user" }
      it { should permit :show    }
      it { should permit :create  }
      it { should permit :update  }
      it { should permit :destroy }
    end
    context "when record == agent" do 
      let(:user) { FactoryGirl.create :user, role: "agent" }
      it { should permit :show    }
      it { should permit :create  }
      it { should permit :update  }
      it { should permit :destroy }
    end
    context "when record == administrator" do 
      let(:user) { FactoryGirl.create :user, role: "admin" }
      it { should permit :show    }
      it { should permit :create  }
      it { should permit :update  }
      it { should permit :destroy }
    end
    context "when record == self" do 
      let(:user) { current_user }
      it { should permit :show    }
      it { should permit :update  }
      it { should_not permit :destroy }
    end
    describe "permitted_attributes" do
      subject { policy.permitted_attributes }
      context "when record == another user (creating & updating)" do
        let(:user) { FactoryGirl.create :user }
        it { should include :role }
        it { should include :organization_id }
        it { should include :active }
        it { should include :verified }
      end
      context "when record == another user (creating)" do
        let(:user) { FactoryGirl.build :user }
        it { should include :email }
      end
      context "when record == another user (updating)" do
        let(:user) { FactoryGirl.create :user }
        it { should_not include :email }
      end
      context "when record == self (updating)" do
        let(:user) { current_user }
        it { should_not include :role }
        it { should_not include :organization_id }
        it { should_not include :active }
        it { should_not include :verified }
        it { should_not include :email }
      end
    end
  end

  context "for an agent" do
    let(:current_user) { FactoryGirl.create :user, role: "agent" }
    let(:user) { User }
    it { should permit :index   }
    context "when record == end_user" do 
      let(:user) { FactoryGirl.create :user, role: "end_user" }
      it { should permit :show    }
      it { should permit :create  }
      it { should permit :update  }
      it { should permit :destroy }
    end
    context "when record == agent" do 
      let(:user) { FactoryGirl.create :user, role: "agent" }
      it { should permit :show    }
      it { should_not permit :create  }
      it { should_not permit :update  }
      it { should_not permit :destroy }
    end
    context "when record == administrator" do 
      let(:user) { FactoryGirl.create :user, role: "admin" }
      it { should permit :show    }
      it { should_not permit :create  }
      it { should_not permit :update  }
      it { should_not permit :destroy }
    end
    context "when record == self" do 
      let(:user) { current_user }
      it { should permit :show    }
      it { should permit :update  }
      it { should_not permit :destroy }
    end
    describe "permitted_attributes" do
      subject { policy.permitted_attributes }
      context "when record == another user (creating & updating)" do
        let(:user) { FactoryGirl.create :user }
        it { should_not include :role }
        it { should include :organization_id }
        it { should include :active }
        it { should include :verified }
      end
      context "when record == another user (creating)" do
        let(:user) { FactoryGirl.build :user }
        it { should include :email }
      end
      context "when record == another user (updating)" do
        let(:user) { FactoryGirl.create :user }
        it { should_not include :email }
      end
      context "when record == self (updating)" do
        let(:user) { current_user }
        it { should_not include :role }
        it { should_not include :organization_id }
        it { should_not include :active }
        it { should_not include :verified }
        it { should_not include :email }
      end
    end
  end

  context "for an end_user" do
    let(:current_user) { FactoryGirl.create :user, role: "end_user" }
    let(:user) { User }
    it { should_not permit :index   }
    context "when record == end_user" do 
      let(:user) { FactoryGirl.create :user, role: "end_user" }
      it { should_not permit :show    }
      it { should_not permit :create  }
      it { should_not permit :update  }
      it { should_not permit :destroy }
    end
    context "when record == agent" do 
      let(:user) { FactoryGirl.create :user, role: "agent" }
      it { should_not permit :show    }
      it { should_not permit :create  }
      it { should_not permit :update  }
      it { should_not permit :destroy }
    end
    context "when record == administrator" do 
      let(:user) { FactoryGirl.create :user, role: "admin" }
      it { should_not permit :show    }
      it { should_not permit :create  }
      it { should_not permit :update  }
      it { should_not permit :destroy }
    end
    context "when record == self" do 
      let(:user) { current_user }
      it { should permit :show    }
      it { should permit :update  }
      it { should_not permit :destroy }
    end
    describe "permitted_attributes" do
      subject { policy.permitted_attributes }
      context "when record == self (updating)" do
        let(:user) { current_user }
        it { should_not include :role }
        it { should_not include :organization_id }
        it { should_not include :active }
        it { should_not include :verified }
        it { should_not include :email }
      end
    end
  end
  

end