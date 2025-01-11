class SalespersonController < ApplicationController
  allow_to_salespersons

  def dashboard
    pays = all_payments_from_store

    all_total = pays.sum(:value)
    failed_total = pays.where(status: "failed").sum(:value)
    pending_total = pays.where(status: "pending").sum(:value)
    approved_total = pays.where(status: "approved").sum(:value)

    total_commission_value = pays.sum(:commission_value)
    average_commission_percentage = pays.average(:commission_percentage_on_sale).to_f

    render json: {
      all_total: all_total.round(2),
      failed_total: failed_total.round(2),
      pending_total: pending_total.round(2),
      approved_total: approved_total.round(2),
      total_commission_value: total_commission_value.round(2),
      average_commission_percentage: average_commission_percentage.round(2)
    }
  end

  def payments
    pays = Payment.where(salesperson_id: current_user.id)
    render json: pays
  end

  def value_from_all_payments
    pays = all_payments_from_store
    sum_pays = pays.sum(:value)
    render json: {
      all_payments: sum_pays
    }
  end
end
