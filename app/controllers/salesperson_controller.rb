class SalespersonController < ApplicationController
  allow_to_salespersons

  def dashboard
    render plain: "This is a dash to only salesperson"
  end

  def payments
    pays = current_user.payments
    render json: { payments: pays }
  end
end
