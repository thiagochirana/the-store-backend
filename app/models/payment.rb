class Payment < ApplicationRecord
  belongs_to :salesperson, class_name: "User", optional: true
  belongs_to :customer

  enum :gateway_used, mercado_pago: "mercado_pago", pagseguro: "pagseguro", prefix: "gateway_"
  enum :status, pending: "pending", approved: "approved", failed: "failed"

  validates :value, presence: true
  validates :gateway_used, inclusion: { in: gateway_useds.keys }

  before_create :generate_status_payment

  private

    def generate_status_payment
      self.status = Payment.statuses.keys.sample
    end
end
