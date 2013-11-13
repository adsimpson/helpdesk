describe OrganizationPolicy do
  subject { OrganizationPolicy.new current_user, organization }

  let(:organization) { FactoryGirl.create :organization }
  
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
