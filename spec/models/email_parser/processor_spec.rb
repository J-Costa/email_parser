require "rails_helper"

RSpec.describe EmailParser::Processor do
  let(:supplier_email) { File.read(Rails.root.join("spec/fixtures/files/email1.eml")) }
  let(:partner_email) { File.read(Rails.root.join("spec/fixtures/files/email4.eml")) }
  let(:unknown_email) { "From: unknown@example.com" }
  let(:log) { Log.new }

  context ".process" do
    describe "when email is from a partner" do
      it "uses the Partner parser" do
        expect(EmailParser::Partner).to receive(:new).and_call_original
        expect {
          EmailParser::Processor.process(partner_email, log: log)
        }.to change { Customer.count }.by(1)
        .and change { log.status }.from("pending").to("success")
      end
    end

    describe "when email is from a supplier" do
      it "uses the Supplier parser" do
        expect(EmailParser::Supplier).to receive(:new).and_call_original
        expect {
          EmailParser::Processor.process(supplier_email, log: log)
        }.to change { Customer.count }.by(1)
        .and change { log.status }.from("pending").to("success")
      end
    end
  end

  describe "when email is from an unknown source" do
    it "uses the Null parser" do
      expect(EmailParser::NullParser).to receive(:new).and_call_original
      expect {
        EmailParser::Processor.process(unknown_email, log: log)
      }.to change { Customer.count }.by(0)
      .and change { log.status }.from("pending").to("failure")
    end
  end
end
