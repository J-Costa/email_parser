require 'rails_helper'

RSpec.describe "Logs", type: :request do
  fixtures :all, :attachments, :blobs

  context "when there are no logs" do
    before do
      Log.destroy_all
    end

    it "returns http success" do
      get logs_path

      expect(response).to have_http_status(:success)
    end
  end

  context "when there are logs" do
    it "returns http success" do
      get logs_path

      expect(response).to have_http_status(:success)
    end
  end
end
