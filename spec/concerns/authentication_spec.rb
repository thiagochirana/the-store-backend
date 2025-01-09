require 'rails_helper'

RSpec.describe Authentication, type: :controller do
  controller(ApplicationController) do
    include Authentication

    before_action :require_shopowner_role, only: [ :restricted_action ]

    def index
      render json: { message: 'Success' }
    end

    def restricted_action
      render json: { message: 'Success' }
    end
  end

  let(:user) { create(:user) }
  let(:access_token) { JWT.encode({ user_id: user.id, exp: 15.minutes.from_now.to_i }, Authentication::SECRET_KEY, 'HS256') }
  let(:refresh_token) { JWT.encode({ user_id: user.id, exp: 2.days.from_now.to_i }, Authentication::SECRET_KEY, 'HS256') }
  let(:expired_token) { JWT.encode({ user_id: user.id, exp: 1.minute.ago.to_i }, Authentication::SECRET_KEY, 'HS256') }

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'restricted_action' => 'anonymous#restricted_action'
    end
  end

  describe 'Token Generation' do
    it 'generates valid access token' do
      token = controller.gen_access_token(user)
      payload = JWT.decode(token, Authentication::SECRET_KEY, true, algorithm: 'HS256').first

      expect(payload['user_id']).to eq(user.id)
      expect(Time.at(payload['exp'])).to be_within(1.second).of(15.minutes.from_now)
    end

    it 'generates valid refresh token' do
      token = controller.gen_refresh_token(user)
      payload = JWT.decode(token, Authentication::SECRET_KEY, true, algorithm: 'HS256').first

      expect(payload['user_id']).to eq(user.id)
      expect(Time.at(payload['exp'])).to be_within(1.second).of(2.days.from_now)
    end
  end

  describe '#require_authentication' do
    context 'with valid access token' do
      it 'allows access' do
        request.headers['Authorization'] = "Bearer #{access_token}"
        get :index
        expect(response).to have_http_status(:ok)
      end

      it 'sets current_user' do
        request.headers['Authorization'] = "Bearer #{access_token}"
        get :index
        expect(controller.current_user).to eq(user)
      end
    end

    context 'with expired token' do
      it 'returns unauthorized error' do
        request.headers['Authorization'] = "Bearer #{expired_token}"
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to include('Login expirado! Por favor faça login')
      end
    end

    context 'without token' do
      it 'returns unauthorized error' do
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to include('É necessário logar-se para acessar funcionalidade')
      end
    end
  end

  describe '#require_shopowner_role' do
    context 'with shopowner role' do
      let(:user) { create(:user, :shopowner) }

      it 'allows access' do
        request.headers['Authorization'] = "Bearer #{access_token}"
        get :restricted_action
        expect(response).to have_http_status(:ok)
      end
    end

    context 'without shopowner role' do
      let(:user) { create(:user, role: :salesperson) }

      it 'returns unauthorized error' do
        request.headers['Authorization'] = "Bearer #{access_token}"
        get :restricted_action
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to include('Você não tem autorização para acessar ou realizar esta ação')
      end
    end
  end

  describe '#require_salesperson_role' do
    before do
      controller.class.allow_to_salespersons only: [ :index ]
    end

    context 'with salesperson role' do
      let(:user) { create(:user, role: :salesperson) }

      it 'allows access' do
        request.headers['Authorization'] = "Bearer #{access_token}"
        get :index
        expect(response).to have_http_status(:ok)
      end
    end

    context 'without salesperson role' do
      let(:user) { create(:user, :shopowner) }

      it 'returns unauthorized error' do
        request.headers['Authorization'] = "Bearer #{access_token}"
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to include('Você não tem autorização para acessar ou realizar esta ação')
      end
    end
  end

  describe '#generate_new_access_token_by_refresh' do
    context 'with valid refresh token' do
      it 'generates new access token' do
        request.headers['Authorization'] = "Bearer #{refresh_token}"
        controller.generate_new_access_token_by_refresh
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('access_token', 'message')
      end
    end

    context 'with expired refresh token' do
      it 'returns unauthorized error' do
        request.headers['Authorization'] = "Bearer #{expired_token}"
        controller.generate_new_access_token_by_refresh
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to include('Login expirado! Por favor faça login')
      end
    end

    context 'with invalid token format' do
      it 'returns unauthorized error' do
        request.headers['Authorization'] = "Invalid #{refresh_token}"
        controller.generate_new_access_token_by_refresh
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to include('Realize novo login pois sessão expirou')
      end
    end
  end

  describe '#token_jwt' do
    it 'returns token when authorization header is valid' do
      request.headers['Authorization'] = "Bearer #{access_token}"
      expect(controller.token_jwt).to eq(access_token)
    end

    it 'handles missing authorization header' do
      controller.token_jwt
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['errors']).to include('É necessário logar-se para acessar funcionalidade')
    end

    it 'handles invalid header format' do
      request.headers['Authorization'] = "Invalid #{access_token}"
      controller.token_jwt
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['errors']).to include('Realize novo login pois sessão expirou')
    end
  end

  describe 'class methods' do
    it 'allows skipping authentication' do
      controller.class.allow_unauthenticated_access only: [ :index ]
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
