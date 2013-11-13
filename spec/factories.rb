FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "User #{n}" }
    sequence(:email) { |n| "user_#{n}@example.com"}
    password "changeme"
    password_confirmation { |u| u.password }
    # verified_at Time.now
  end
  
  factory :group do
    sequence(:name)  { |n| "Group #{n}" }
  end
  
  factory :invalid_group, parent: :group do
    name nil
  end
  
  factory :group_membership do
    user
    group
  end
  
  factory :organization do
    sequence(:name)  { |n| "Organization #{n}" }
  end
  
  factory :domain do
    sequence(:name)  { |n| "domain#{n}.com" }
  end
end