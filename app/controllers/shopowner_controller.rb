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
    user = current_user.salespersons.find_by(id: params[:user_id])
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
    render json: salespersons.map { |s|
      {
        id: s.id,
        name: s.name,
        email: s.email,
        commission_percentage: s.commission.percentage
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
