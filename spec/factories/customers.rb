FactoryBot.define do
  factory :customer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    telephone { "(62)99999-0123" }
  end
end
