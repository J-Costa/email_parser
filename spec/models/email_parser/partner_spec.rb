require "rails_helper"

RSpec.describe EmailParser::Partner do
  let(:valid_email) { File.read(Rails.root.join("spec/fixtures/files/email4.eml")) }
  let(:invalid_email) { File.read(Rails.root.join("spec/fixtures/files/email6.eml")) }
  let(:log) { Log.new }

  context "#parse" do
    describe "with valid email and log" do
      subject { EmailParser::Partner.new(valid_email, log: log) }

      it "parses successfully and creates a Customer record" do
        expect { subject.parse }.to change { Customer.count }.by(1)
        .and change { log.status }.from("pending").to("success")
        expect(subject.success).to be true
        expect(subject.errors).to be_empty
      end
    end

    describe "with invalid email and log" do
      subject { EmailParser::Partner.new(invalid_email, log: log) }

      it "fails to parse and does not create a Customer record" do
        expect { subject.parse }.not_to change { Customer.count }
        expect(log.status).to eq("failure")
        expect(subject.success).to be false
        expect(subject.errors).not_to be_empty
      end
    end
  end

  describe "valid email and without log" do
    subject { EmailParser::Partner.new(valid_email) }

    it "parses successfully and creates a Customer record" do
      expect { subject.parse }.to change { Customer.count }.by(1)
      expect(subject.success).to be true
      expect(subject.errors).to be_empty
    end
  end

  describe "invalid email and without log" do
    subject { EmailParser::Partner.new(invalid_email) }

    it "fails to parse and does not create a Customer record" do
      expect { subject.parse }.not_to change { Customer.count }
      expect(subject.success).to be false
      expect(subject.errors).not_to be_empty
    end
  end
end
