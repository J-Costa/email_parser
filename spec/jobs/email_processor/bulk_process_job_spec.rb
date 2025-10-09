require "rails_helper"

RSpec.describe EmailProcessor::BulkProcessJob, type: :job do
  describe "#perform" do
    let(:log1) { Log.create.tap { it.eml_file.attach(file_fixture("email1.eml")) } }
    let(:log2) { Log.create.tap { it.eml_file.attach(file_fixture("email2.eml")) } }
    let(:log3) { Log.create.tap { it.eml_file.attach(file_fixture("email3.eml")) } }

    it "enqueues EmailProcessor::ProcessJob for each log id" do
      expect {
        described_class.new.perform([ log1.id, log2.id, log3.id ])
      }.to have_enqueued_job(EmailProcessor::ProcessJob).exactly(3).times
    end

    it "only processes logs that exist" do
      non_existent_log_id = Log.maximum(:id).to_i + 1

      expect {
        described_class.new.perform([ log1.id, non_existent_log_id, log2.id ])
      }.to have_enqueued_job(EmailProcessor::ProcessJob).exactly(2).times
    end
  end
end
