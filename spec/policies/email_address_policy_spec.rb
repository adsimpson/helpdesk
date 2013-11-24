require 'spec_helper'

describe EmailAddressPolicy do
  let(:verified) { true }
  let(:role) { "end_user" }
  let(:user) { FactoryGirl.create :user, role: role }
  let!(:primary_resource) { FactoryGirl.create :email_address, user: user, primary: true }
  let(:resource) { FactoryGirl.create :email_address, user: user, verified: verified }
  let(:policy) { EmailAddressPolicy.new current_user, resource }
  subject { policy }
  
  context "when record == self" do 
    let(:current_user) { FactoryGirl.create :user, role: ["end_user","agent","admin"].sample }
    let(:user) { current_user }
    it { should permit :show    }
    it { should permit :create  }
    it { should permit :update  }
    it { should permit :destroy }      
    context "when primary == true" do
      before { resource.update_attributes(primary: true) }
      it { should_not permit :destroy }
    end    
  end
  
  context "for an administrator" do
    let(:current_user) { FactoryGirl.create :user, role: "admin" }
    # let(:user_email) { UserEmail }
    # it { should permit :index   }
    context "when record == end_user" do 
      let(:role) { "end_user" }
      it { should permit :show    }
      it { should permit :create  }
      it { should permit :update  }
      it { should permit :destroy }
      context "when primary == true" do
        before { resource.update_attributes(primary: true) }
        it { should_not permit :destroy }
      end    
    end
    context "when record == agent" do 
      let(:role) { "agent" }
      it { should permit :show    }
      it { should permit :create  }
      it { should permit :update  }
      it { should permit :destroy }      
      context "when primary == true" do
        before { resource.update_attributes(primary: true) }
        it { should_not permit :destroy }
      end    
    end
    context "when record == admin" do 
      let(:role) { "agent" }
      it { should permit :show    }
      it { should permit :create  }
      it { should permit :update  }
      it { should permit :destroy }      
      context "when primary == true" do
        before { resource.update_attributes(primary: true) }
        it { should_not permit :destroy }
      end    
    end
  end
  
  context "for an agent" do
    let(:current_user) { FactoryGirl.create :user, role: "agent" }
    context "when record == end_user" do 
      let(:role) { "end_user" }
      it { should permit :show    }
      it { should permit :create  }
      it { should permit :update  }
      it { should permit :destroy }      
      context "when primary == true" do
        before { resource.update_attributes(primary: true) }
        it { should_not permit :destroy }
      end    
    end
    context "when record == agent" do 
      let(:role) { "agent" }
      it { should permit :show    }
      it { should_not permit :create  }
      it { should_not permit :update  }
      it { should_not permit :destroy }      
    end
    context "when record == admin" do 
      let(:role) { "agent" }
      it { should permit :show    }
      it { should_not permit :create  }
      it { should_not permit :update  }
      it { should_not permit :destroy }      
    end
  end

  context "for an end_user" do
    let(:current_user) { FactoryGirl.create :user, role: "end_user" }
    context "when record == end_user" do 
      let(:role) { "end_user" }
      it { should_not permit :show    }
      it { should_not permit :create  }
      it { should_not permit :update  }
      it { should_not permit :destroy }      
    end
    context "when record == agent" do 
      let(:role) { "agent" }
      it { should_not permit :show    }
      it { should_not permit :create  }
      it { should_not permit :update  }
      it { should_not permit :destroy }      
    end
    context "when record == admin" do 
      let(:role) { "agent" }
      it { should_not permit :show    }
      it { should_not permit :create  }
      it { should_not permit :update  }
      it { should_not permit :destroy }      
    end
  end

end