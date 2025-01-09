require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:user) { create(:user) }
  let(:salesperson) { create(:user, shopowner: user) }
  let(:customer) { create(:customer) }
  let!(:payment) { create(:payment, salesperson: salesperson, customer: customer) }

  before do
    @access_token = gen_access_token(user)
    request.headers["authorization"] = "Bearer #{@access_token}"
  end

  describe "GET #list_payments" do
    it "returns payments with pagination and filters" do
      get :list_payments, params: { page: 1, per_page: 10 }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response).to have_key("payments")
      expect(json_response["pagination"]).to have_key("current_page")
      expect(json_response["pagination"]).to have_key("total_pages")
    end

    it "filters payments by status" do
      get :list_payments, params: { status: "approved", page: 1, per_page: 10 }

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response["payments"]).to all(include("status" => "approved"))
    end
  end
end
