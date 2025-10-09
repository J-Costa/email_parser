require "rails_helper"

RSpec.describe EmailProcessor::ProcessJob, type: :job do
  describe "#perform" do
    let(:log) { Log.create.tap { |it| it.eml_file.attach(file_fixture("email1.eml")) } }

    it "processes the email and updates the log status to completed" do
      expect(log.status).to eq("pending")

      expect {
        described_class.new.perform(log.id)
      }.to change { log.reload.status }.from("pending").to("success")
      expect(log.extracted_info).to be_present
    end
  end
end
