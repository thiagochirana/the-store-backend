FactoryBot.define do
  factory :payment do
    val = Faker::Commerce.price(range: 1.0..10000.0)
    perc_com = Faker::Commerce.price(range: 0.0..100.0)
    val_com = (val * perc_com) / 100

    association :customer, factory: :customer
    value { Faker::Commerce.price(range: 10.0..1000.0) }
    gateway_used { Payment.gateway_useds.keys.sample }
    commission_percentage_on_sale { 0.0 }
    commission_value { 0.0 }

    trait :with_salesperson do
      association :salesperson, factory: :user
      commission_percentage_on_sale { perc_com }
      commission_value { val_com }
    end
  end
end
