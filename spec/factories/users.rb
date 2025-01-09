FactoryBot.define do
  factory :user do
    pass = Faker::Alphanumeric.alpha(number: 8)

    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }

    trait :without_password do
      password { nil }
      password_confirmation { nil }
    end

    trait :with_short_password do
      password { Faker::Alphanumeric.alpha(number: 7) }
      password_confirmation { password }
    end

    trait :with_mismatched_password do
      password { Faker::Alphanumeric.alpha(number: 8) }
      password_confirmation { Faker::Alphanumeric.alpha(number: 8) }
    end

    trait :with_spaced_pass do
      password { "   #{Faker::Alphanumeric.alpha(number: 8)}  " }
      password_confirmation { "   #{Faker::Alphanumeric.alpha(number: 8)}  " }
    end

    trait :with_invalid_pass_chars do
      password { "Ç#{pass}" }
      password_confirmation { "Ç#{pass}" }
    end
  end
end
