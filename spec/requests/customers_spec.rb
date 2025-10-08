require 'rails_helper'

RSpec.describe "Customers", type: :request do
  fixtures :customers

  describe "GET /index" do
    context "when there are no customers" do
      before do
        Customer.destroy_all
      end

      it "returns http success" do
        get customers_path

        expect(Customer.count).to be_zero
        expect(response).to have_http_status(:success)
      end
    end

    context "when there are customers" do
      it "returns http success" do
        get customers_path

        expect(Customer.count).to be_positive
        expect(response).to have_http_status(:success)
      end
    end
  end
end
