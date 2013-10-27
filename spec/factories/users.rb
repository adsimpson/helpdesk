FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "User #{n}" }
    sequence(:email) { |n| "user_#{n}@example.com"}
    password 'changeme'
    password_confirmation { |u| u.password }
    # verified_at Time.now
  end
end