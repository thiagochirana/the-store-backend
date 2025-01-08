class SalespersonController < ApplicationController
  allow_to_salespersons

  def dashboard
    render plain: "This is a dash to only salesperson"
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
