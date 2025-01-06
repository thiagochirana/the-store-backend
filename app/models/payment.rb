class Payment < ApplicationRecord
  belongs_to :salesperson, class_name: "User"
  belongs_to :customer

  enum :gateway_used, mercado_pago: "mercado_pago", pagseguro: "pagseguro", prefix: :gateway
  enum :status, pending: "pending", approved: "approved", falied: "falied"
end
