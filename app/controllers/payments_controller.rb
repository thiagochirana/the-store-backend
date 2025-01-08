class PaymentsController < ApplicationController
  allow_to_shopowners

  def list_payments
    payments = Payment.where(salesperson_id: current_user.salespersons.select(:id))

    payments = payments.where(salesperson_id: params[:salesperson_id]) if params[:salesperson_id].present?

    payments = payments.where("value >= ?", params[:min_value]) if params[:min_value].present?
    payments = payments.where("value <= ?", params[:max_value]) if params[:max_value].present?

    payments = payments.where("commission_percentage_on_sale >= ?", params[:min_commission_percentage]) if params[:min_commission_percentage].present?
    payments = payments.where("commission_percentage_on_sale <= ?", params[:max_commission_percentage]) if params[:max_commission_percentage].present?

    payments = payments.where("commission_value >= ?", params[:min_commission_value]) if params[:min_commission_value].present?
    payments = payments.where("commission_value <= ?", params[:max_commission_value]) if params[:max_commission_value].present?

    payments = payments.where(status: params[:status]) if params[:status].present?

    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 10
    total_pages = (payments.count / per_page.to_f).ceil

    payments = payments.offset((page - 1) * per_page).limit(per_page)


    if payments.any?
      render json: {
        payments: payments,
        pagination: {
          current_page: page,
          per_page: per_page,
          total_pages: total_pages,
          total_records: payments.count
        }
      }
    else
      render json: []
    end
  end


  def generate_payment
    if payment_params[:salesperson_id].present?
      salesperson = current_user.salespersons.find_by(id: payment_params[:salesperson_id])
      render json: { errors: [ "Vendedor não encontrado" ] }, status: :bad_request unless salesperson.present?
    end

    customer = Customer.find_or_initialize_by(payment_params[:customer])
    render json: { errors: customer.errors.full_messages }, status: :bad_request unless customer.save

    pay = Payment.new(payment_params.except(:customer, :custom_commission_percent))
    pay.salesperson = salesperson if salesperson.present?
    pay.customer = customer

    if payment_params[:custom_commission_percent].present?
      pay.commission_percentage_on_sale = payment_params[:custom_commission_percent].to_f
    else
      pay.commission_percentage_on_sale = salesperson&.commission&.percentage || 0
    end

    pay.commission_value = (pay.value * pay.commission_percentage_on_sale) / 100

    render json: { errors: pay.errors.full_messages }, status: :bad_request unless pay.save

    render json: { message: "Pagamento processado! Verifique o status de pagamento" }, status: :created
  end

  def show_payment
    render json: { errors: [ "Venda não especificada para consulta" ] }, status: :bad_request unless params[:payment_id]

    payments = Payment.where(salesperson_id: current_user.salespersons.select(:id))

    pay = payments.where(id: params[:payment_id]).first
    if pay.present?
      render json: { payment: pay }
    else
      render json: { errors: [ "Pagamento não encontrado" ] }, status: :not_found
    end
  end

  private

  def payment_params
    params.permit(
      :gateway_used,
      :value,
      :salesperson_id,
      :custom_commission_percent,
      customer: [ :name, :email, :telephone ]
    )
  end
end
