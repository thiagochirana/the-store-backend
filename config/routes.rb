Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  scope :backend do
    scope :v1 do
      scope :auth do
        scope :login do
          post "/", to: "sessions#create", as: :login
          post "refresh", to: "sessions#refresh"
        end
      end
      scope :shopowner do
        get "/", to: "shopowner#dashboard"
        scope :salespersons do
          get "/", to: "shopowner#list_salespersons"
          get "/about", to: "shopowner#about_salesperson"
          post "/", to: "shopowner#new_salesperson"
          put "commission", to: "shopowner#adjust_percentage_commission"
        end
      end

      scope :payments do
        get "/", to: "payments#list_payments"
        get "details", to: "payments#show_payment"
        post "create", to: "payments#generate_payment"
      end
    end
  end
end
