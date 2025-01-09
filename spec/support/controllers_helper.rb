module ControllersHelpers
  def authenticate_user(user = nil)
    user ||= create(:user) # Cria ou usa um usuário padrão
    token = gen_access_token(user)
    request.headers["Authorization"] = "Bearer #{token}"
  end
end

RSpec.configure do |config|
  config.include ControllersHelpers, type: :controller
end
