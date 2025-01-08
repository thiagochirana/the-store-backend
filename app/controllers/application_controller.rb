class ApplicationController < ActionController::API
  include Authentication

  def all_payments_from_store
    salesperson_ids = current_user.salespersons&.pluck(:id) + [ current_user.id ]
    Payment.where(salesperson_id: salesperson_ids)
  end
end
