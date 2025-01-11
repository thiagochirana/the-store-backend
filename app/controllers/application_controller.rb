class ApplicationController < ActionController::API
  include Authentication

  def all_payments_from_store
    if current_user.shopowner?
      salesperson_ids = current_user.salespersons.pluck(:id) + [ current_user.id ]
    else
      salesperson_ids = [ current_user.id ]
    end
    Payment.where(salesperson_id: salesperson_ids)
  end
end
