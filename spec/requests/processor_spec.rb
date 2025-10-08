require 'rails_helper'

RSpec.describe "Processors", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get new_processor_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    let(:file1) { fixture_file_upload(file_fixture("email1.eml"), "message/rfc822") }
    let(:file2) { fixture_file_upload(file_fixture("email2.eml"), "message/rfc822") }

    context "with valid files" do
      it "process a single file" do
        post processor_path, params: { files: [ file1 ] }

        follow_redirect!
        expect(flash[:notice]).to be_present
        expect(response).to have_http_status(:success)
      end

      it "process multiple files" do
        post processor_path, params: { files: [ file1, file2 ] }

        follow_redirect!
        expect(flash[:notice]).to be_present
        expect(response).to have_http_status(:success)
      end
    end

    context "with no files" do
      it "shows an alert" do
        post processor_path, params: { files: [] }

        follow_redirect!
        expect(flash[:alert]).to be_present
        expect(response).to have_http_status(:success)
      end
    end
  end
end
