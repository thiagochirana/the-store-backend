FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "test@example.com" }
    password { "password123" }
    role { :salesperson }
    commission { association :commission }

    trait :shopowner do
      role { :shopowner }
    end
  end
end
