module AuthHelper
  SECRET_KEY = ENV["SECRET_KEY"] || Rails.application.secret_key_base

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
end

RSpec.configure do |config|
  config.include AuthHelper
end
