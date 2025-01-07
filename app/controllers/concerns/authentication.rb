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
      before_action :require_shopowner_role
    end

    def allow_to_salespersons(**options)
      before_action :require_salesperson_role
    end
  end

  def gen_access_token(user)
    generate_jwt_for(user, "access", expiration_time: 15.minutes.from_now)
  end

  def gen_refresh_token(user)
    generate_jwt_for(user, "refresh", expiration_time: 2.days.from_now)
  end

  def generate_jwt_for(user, token_type, expiration_time:)
    payload = {
      user_id: user.id,
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
    return if current_user

    request_need_authentication
    nil
  end

  def require_shopowner_role
    return nil if current_user.shopowner?

    unauthorized_request
    nil
  end

  def require_salesperson_role
    return nil if current_user.salesperson? || current_user.shopowner?

    unauthorized_request
    nil
  end

  def request_need_authentication
    render plain: "É necessário logar-se", status: :unauthorized unless response.body.present?
  end

  def unauthorized_request
    render plain: "Você não tem autorização para fazer isso", status: :unauthorized
  end

  def decode_token_jwt
    unless token_jwt
      request_need_authentication
      return
    end

    begin
      JWT.decode(token_jwt, SECRET_KEY, true, algorithm: "HS256").first
    rescue JWT::ExpiredSignature
      render json: { error: "Login expirado! Por favor faça login" }, status: :unauthorized
      nil
    rescue JWT::DecodeError
      render json: { error: "Erro ao lhe identificar, por favor, relogue" }, status: :unauthorized
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
      render json: { error: "Login expirado! Por favor faça login" }, status: :unauthorized
      return
    rescue JWT::DecodeError
      render json: { error: "Erro ao lhe identificar, por favor, relogue" }, status: :unauthorized
      return
    rescue JWT::VerificationError
      render json: { error: "Não foi possível validar seu acesso, por favor, relogue" }, status: :unauthorized
      return
    end


    if decoded_token["exp"] && Time.at(decoded_token["exp"]).utc < Time.current
      render json: { error: "Realize novo login!" }, status: :unauthorized
      return
    end

    user = User.find decoded_token["user_id"]

    render json: { access_token: gen_access_token(user), message: "Novo token gerado!" }
  end


  def token_jwt
    request.headers[:authorization]&.split(" ")&.last
  end
end
