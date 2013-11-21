FactoryGirl.define do
  
  # user
  factory :user do
    sequence(:name)  { |n| "User #{n}" }
    sequence(:email) { |n| "user_#{n}@example.com"}
    password "changeme"
    password_confirmation { |u| u.password }
    
    factory :verified_user do
      verified true
    end
  end
  
  factory :invalid_user, parent: :user do
    name nil
  end
  
  # access_token
  factory :access_token do
    user
  end
  
  # password_reset_token
  factory :password_reset_token do
    user
    expires_at  1.hour.from_now
  end
  
  # email_verification_token
  factory :email_verification_token do
    user
    expires_at  72.hours.from_now
  end
  
  # group
  factory :group do
    sequence(:name)  { |n| "Group #{n}" }
  end
  
  factory :invalid_group, parent: :group do
    name nil
  end
  
  # group_membership
  factory :group_membership do
    association :user, factory: :user, role: "agent"
    group
  end
  
  # organization
  factory :organization do
    sequence(:name)  { |n| "Organization #{n}" }
    sequence(:external_id) { |n| "organization_#{n}"}

    factory :organization_with_domains do
      ignore do
        domains_count 2
      end
      after(:create) do |organization, evaluator|
        FactoryGirl.create_list(:domain, evaluator.domains_count, organization: organization)
      end
    end
  end
  
  factory :invalid_organization, parent: :organization do
    name nil
  end
  
  # domain
  factory :domain do
    sequence(:name)  { |n| "domain#{n}.com" }
    organization
  end
  
end