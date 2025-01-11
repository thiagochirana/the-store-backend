class ShopownerController < ApplicationController
  allow_to_shopowners

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


  def new_salesperson
    begin
      user = User.new(salesperson_params)
      user.shopowner = current_user
      user.save!

      com_perc = params[:percentual_commission].to_f
      Commission.create!(percentage: (com_perc > 0 ? com_perc : 0), user: user)

      render json: { message: "Usuário cadastrado com sucesso!" }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue Exception => e
      render json: { errors: [ e.message ] }, status: :unprocessable_entity
    end
  end

  def about_salesperson
    user = current_user.salespersons.where(id: params[:user_id]).first
    if user.present?
      render json: {
        id: user.id,
        name: user.name,
        email: user.email,
        commission_percentage: user.commission.percentage
      }
    else
      render json: { errors: [ "Vendedor não encontrado" ] }, status: :not_found
    end
  end

  def list_salespersons
    salespersons = current_user.salespersons
    salespersons = salespersons.where("name LIKE ?", "%#{params[:name]}%") if params[:name].present?
    salespersons = salespersons.where("email LIKE ?", "%#{params[:email]}%") if params[:email].present?

    page = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = params[:per_page].to_i > 0 ? params[:per_page].to_i : 10
    total_pages = (salespersons.count / per_page.to_f).ceil
    salespersons = salespersons.offset((page - 1) * per_page).limit(per_page)

    render json: {
      salespersons: salespersons.map { |s|
        {
          id: s.id,
          name: s.name,
          email: s.email,
          created_at: s.created_at,
          commission_percentage: s.commission&.percentage || 0.0
        }
      },
      pagination: {
        current_page: page,
        per_page: per_page,
        total_pages: total_pages,
        total_records: salespersons.count
      }
    }
  end

  def list_all_salespersons
    salespersons = current_user.salespersons.order(:name)

    render json: {
      salespersons: salespersons.map { |s|
        {
          id: s.id,
          name: s.name
        }
      }
    }
  end

  def update
    user = current_user.salespersons.find_by(id: salesperson_edit_params[:user_id])
    if user.commission.update!(percentage: salesperson_edit_params[:percentual_commission]) && user.update!(salesperson_edit_params.except(:user_id, :percentual_commission))
      render json: { message: "Usuario atualizado com sucesso!" }
    else
      render json: { errors: user.errors.full_messages || user.commission.errors.full_messages }, status: :bad_request
    end
  end

  def value_from_all_payments
    pays = all_payments_from_store
    sum_pays = pays.sum(:value)
    render json: {
      all_payments: sum_pays
    }
  end

  private

    def salesperson_params
      params.permit(:name, :email, :password, :password_confirmation)
    end

    def salesperson_edit_params
      params.permit(:user_id, :name, :email, :percentual_commission)
    end

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
