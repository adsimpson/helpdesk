FactoryGirl.define do
  
  # user
  factory :user do
    sequence(:name)  { |n| "User #{n}" }
    sequence(:email_addresses_attributes) { |n| [{value: "user.#{n}@example.com"}]}
    password "changeme"
    password_confirmation { |u| u.password }
    
    #after(:build) do |user|
    #  unless user.email_addresses.first
    #    user.email_addresses.new({value: "#{user.name.downcase}@example.com"})
    #  end
    #end
    
 end
  
  factory :invalid_user, parent: :user do
    name nil
  end
  
  # user_email
  factory :email_address do
   sequence(:value) { |n| "user_#{n}@example.com"}
   user
  end
  
  # email_verification_token
  factory :email_verification_token do
    email_address
    expires_at  72.hours.from_now
  end
  
  # access_token
  factory :access_token do
    email_address
  end
  
  # password_reset_token
  factory :password_reset_token do
    email_address
    expires_at  1.hour.from_now
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
  
  # ticket
  factory :ticket do
    sequence(:subject)  { |n| "Example subject #{n}" }
    sequence(:description)  { |n| "Example description #{n}" }
    association :requester, factory: :user
    association :assignee, factory: :user, role: "agent"
  end

  factory :ticket_comment do
    ticket
    association :author, factory: :user
    sequence(:body)  { |n| "Example body text #{n}" }
  end

end