require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe "associations" do
    it { should belong_to(:salesperson).class_name("User").optional }
    it { should belong_to(:customer) }
  end

  describe "is valid" do
    it { should validate_presence_of(:value) }
  end

  describe "is invalid" do
  end

  describe "callbacks" do
    it "define status before create payment" do
      payment = create(:payment)
      expect(Payment.statuses.keys).to include(payment.status)
    end
  end
end
