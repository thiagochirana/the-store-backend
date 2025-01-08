require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe "associações" do
    it { should belong_to(:salesperson).class_name("User").optional }
    it { should belong_to(:customer) }
  end

  describe "validações" do
    it { should validate_presence_of(:value) }

    it "valida inclusão dos gateways permitidos" do
      should validate_inclusion_of(:gateway_used)
        .in_array(Payment.gateway_useds.keys)
    end
  end

  describe "callbacks" do
    it "define status antes de criar o pagamento" do
      payment = create(:payment)
      expect(Payment.statuses.keys).to include(payment.status)
    end
  end
end
