require 'rails_helper'

RSpec.describe Authentication, type: :controller do
  controller(ApplicationController) do
    include Authentication

    def index
      render json: { message: 'Success' }
    end
  end

  let(:user) { create(:user) }
  let(:token) { JWT.encode({ user_id: user.id, exp: 15.minutes.from_now.to_i }, Authentication::SECRET_KEY, 'HS256') }
  let(:expired_token) { JWT.encode({ user_id: user.id, exp: 1.minute.ago.to_i }, Authentication::SECRET_KEY, 'HS256') }

  describe '#require_authentication' do
    context 'with valid token' do
      it 'allows access' do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
        expect(response).to have_http_status(:ok)
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
    before do
      controller.class.allow_to_shopowners only: [ :index ]
    end

    context 'without shopowner role' do
      before { allow(user).to receive(:shopowner?).and_return(false) }

      it 'returns unauthorized error' do
        request.headers['Authorization'] = "Bearer #{token}"
        get :index
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['errors']).to include('Você não tem autorização para acessar ou realizar esta ação')
      end
    end
  end

  describe '#token_jwt' do
    it 'returns token when authorization header is valid' do
      request.headers['Authorization'] = "Bearer #{token}"
      expect(controller.token_jwt).to eq(token)
    end

    it 'renders error for missing token' do
      get :index
      expect(response).to have_http_status(:unauthorized)
    end

    it 'renders error for invalid header format' do
      request.headers['Authorization'] = "Invalid #{token}"
      get :index
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)['errors']).to include('Realize novo login pois sessão expirou')
    end
  end
end
