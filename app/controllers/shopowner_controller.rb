class ShopownerController < ApplicationController
  allow_to_shopowners

  def dashboard
  end

  def new_salesperson
    user = User.new(salesperson_params)
    user.shopowner = current_user

    if user.save
      user.commission.update(percentage: params[:percentual_commission].to_f) if params[:percentual_commission]
      render json: { message: "Usuário cadastrado com sucesso!" }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :bad_request
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

  def adjust_percentage_commission
    user = current_user.salespersons.find_by(id: params[:user_id])
    if user.commission.update(percentage: params[:new_percentual_commission])
      render json: { message: "Commissão atualizada para #{params[:new_percentual_commission]} % " }
    else
      render json: { errors: user.commission.errors.full_messages }, status: :bad_request
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
