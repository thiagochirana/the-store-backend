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
          get "/all", to: "shopowner#list_all_salespersons"
          get "/about", to: "shopowner#about_salesperson"
          post "/", to: "shopowner#new_salesperson"
          put "update", to: "shopowner#update"
        end
      end

      scope :payments do
        get "/", to: "payments#list_payments"
        get "details", to: "payments#show_payment"
        post "create", to: "payments#generate_payment"

        get "shopowner/sum_values", to: "shopowner#value_from_all_payments"
        get "salesperson/sum_values", to: "salesperson#value_from_all_payments"
      end

      scope :salesperson do
        get "/", to: "salesperson#dashboard"
        get "/payments", to: "salesperson#payments"
      end
    end
  end
end
