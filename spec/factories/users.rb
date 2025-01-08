FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "test@example.com" }
    password { "password123" }
    role { :salesperson }

    trait :shopowner do
      role { :shopowner }
    end
  end
end
