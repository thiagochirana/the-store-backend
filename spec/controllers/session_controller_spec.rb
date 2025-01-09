require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe "POST #create" do
    let(:user) { create(:user) }

    context "with valid credentials" do
      it "returns access and refresh tokens" do
        post :create, params: { login: user.email, password: "password123" }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response).to include("access_token", "refresh_token", "message")
        expect(json_response["message"]).to eq("Logado com sucesso!")
      end
    end

    context "with invalid credentials" do
      it "returns unauthorized with invalid login" do
        post :create, params: { login: "wrong@example.com", password: "password123" }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response["errors"][0]).to eq("Login e senha inválidos")
      end

      it "returns unauthorized with invalid password" do
        post :create, params: { login: user.email, password: "wrongpassword" }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response["errors"][0]).to eq("Login e senha inválidos")
      end
    end
  end

  describe "POST #refresh" do
    let(:user) { create(:user) }
    let(:refresh_token) { gen_refresh_token(user) }

    context "with valid refresh token" do
      it "returns a new access token" do
        request.headers["Authorization"] = "Bearer #{refresh_token}"
        post :refresh

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response).to include("access_token")
      end
    end

    context "with invalid refresh token" do
      it "returns unauthorized and a error message" do
        request.headers["Authorization"] = "Bearer invalidtoken"
        post :refresh

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)

        expect(json_response["errors"][0]).to eq("Erro ao lhe identificar, por favor, relogue")
      end
    end
  end
end

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
