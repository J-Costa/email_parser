require 'rails_helper'

RSpec.describe "Logs", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/logs/index"
      expect(response).to have_http_status(:success)
    end
  end

end
