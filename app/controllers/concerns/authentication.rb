module Authentication
  extend ActiveSupport::Concern

  SECRET_KEY = ENV["SECRET_KEY"] || Rails.application.secret_key_base

  included do
    before_action :require_authentication
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end

    def allow_to_shopowners(**options)
      before_action :require_shopowner_role, **options
    end

    def allow_to_salespersons(**options)
      before_action :require_salesperson_role, **options
    end
  end

  def gen_access_token(user)
    generate_jwt_for(user, "access", expiration_time: 6.hours.from_now)
  end

  def gen_refresh_token(user)
    generate_jwt_for(user, "refresh", expiration_time: 2.days.from_now)
  end

  def generate_jwt_for(user, token_type, expiration_time:)
    payload = {
      user_id: user.id,
      role: user.role,
      exp: expiration_time.to_i
    }

    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def current_user
    return @user if @user

    payload = decode_token_jwt
    @user = User.find_by(id: payload["user_id"]) if payload
    @user
  end

  def require_authentication
    unless current_user
      request_need_authentication
      nil
    end
  end

  def require_shopowner_role
    unless current_user.shopowner?
      unauthorized_request
      nil
    end
  end

  def require_salesperson_role
    unless current_user.salesperson?
      unauthorized_request
      nil
    end
  end

  def request_need_authentication
    unless response.body.present?
      render json: { errors: [ "É necessário logar-se para acessar funcionalidade" ] }, status: :unauthorized
      nil
    end
  end

  def unauthorized_request
    render json: { errors: [ "Você não tem autorização para acessar ou realizar esta ação" ] }, status: :forbidden
    nil
  end

  def decode_token_jwt
    unless token_jwt
      request_need_authentication
      return
    end

    begin
      JWT.decode(token_jwt, SECRET_KEY, true, algorithm: "HS256").first
    rescue JWT::ExpiredSignature
      render json: { errors: [ "Login expirado! Por favor faça login" ] }, status: :unauthorized
      nil
    rescue JWT::DecodeError
      render json: { errors: [ "Erro ao lhe identificar, por favor, relogue" ] }, status: :unauthorized
      nil
    end
  end

  def generate_new_access_token_by_refresh
    unless token_jwt
      request_need_authentication
      return
    end

    begin
      decoded_token = JWT.decode(token_jwt, SECRET_KEY, true, algorithm: "HS256").first
    rescue JWT::ExpiredSignature
      render json: { errors: [ "Login expirado! Por favor faça login" ] }, status: :unauthorized
      return
    rescue JWT::DecodeError
      render json: { errors: [ "Erro ao lhe identificar, por favor, relogue" ] }, status: :unauthorized
      return
    rescue JWT::VerificationError
      render json: { errors: [ "Não foi possível validar seu acesso, por favor, relogue" ] }, status: :unauthorized
      return
    end

    if decoded_token["exp"] && Time.at(decoded_token["exp"]).utc < Time.current
      render json: { errors: [ "Realize novo login!" ] }, status: :unauthorized
      return
    end

    user = User.find decoded_token["user_id"]

    render json: { access_token: gen_access_token(user), message: "Novo token gerado!" }
  end

  def token_jwt
    unless request.headers[:authorization].present?
      request_need_authentication
      return
    end

    first = request.headers[:authorization]&.split(" ")&.first
    unless first == "Bearer"
      render json: { errors: [ "Realize novo login pois sessão expirou" ] }, status: :unauthorized
      return
    end

    request.headers[:authorization]&.split(" ")&.last
  end
end
