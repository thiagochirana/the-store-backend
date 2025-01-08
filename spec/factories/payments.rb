FactoryBot.define do
  factory :payment do
    association :salesperson, factory: :user # Associa com um usuário
    value { 100.0 }
    gateway_used { "mercado_pago" }
    association :customer, factory: :user
    commission_percentage_on_sale { 10.0 }
    commission_value { 10.0 }
    status { "pending" }
  end
end
