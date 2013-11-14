FactoryGirl.define do
  
  # user
  factory :user do
    sequence(:name)  { |n| "User #{n}" }
    sequence(:email) { |n| "user_#{n}@example.com"}
    password "changeme"
    password_confirmation { |u| u.password }
  end
  
  # access_token
  factory :access_token do
    user
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
    user
    group
  end
  
  # organization
  factory :organization do
    sequence(:name)  { |n| "Organization #{n}" }
  end
  
  # domain
  factory :domain do
    sequence(:name)  { |n| "domain#{n}.com" }
  end
  
end