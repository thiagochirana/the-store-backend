class Payment < ApplicationRecord
  belongs_to :salesperson, class_name: "User", optional: true
  belongs_to :customer

  enum :gateway_used, mercado_pago: "mercado_pago", pagseguro: "pagseguro", prefix: "gateway_"
  enum :status, pending: "pending", approved: "approved", failed: "failed"

  validates :value, presence: true
  validates :gateway_used, inclusion: { in: gateway_useds.keys }

  before_create :generate_status_payment
  before_create :adjust_value_to_float

  def generate_status_payment
    self.status = Payment.statuses.keys.sample
  end

  def adjust_value_to_float
    self.value = self.value.to_f if self.value
  end
end
