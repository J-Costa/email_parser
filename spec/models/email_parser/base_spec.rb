require "rails_helper"

RSpec.describe EmailParser::Base do
  let(:valid_email) { File.read(Rails.root.join("spec/fixtures/files/email1.eml")) }
  let(:invalid_email) { File.read(Rails.root.join("spec/fixtures/files/email3.eml")) }
  let(:log) { Log.new }

  describe "#extract_from_email_address" do
    it "extracts email address from valid raw email" do
      email = EmailParser::Base.extract_from_email_address(valid_email)
      expect(email).to eq("loja@fornecedorA.com")
    end

    it "extracts email address from valid raw email" do
      email = EmailParser::Base.extract_from_email_address(invalid_email)
      expect(email).to eq("loja@fornecedorA.com")
    end
  end

  context "#parse" do
    describe "with valid email and log" do
      subject { EmailParser::Base.new(valid_email, log: log) }

      it "parses successfully and creates a Customer record" do
        expect { subject.parse }.to change { Customer.count }.by(1)
        .and change { log.status }.from("pending").to("success")
        expect(subject.success).to be true
        expect(subject.errors).to be_empty
      end
    end

    describe "with invalid email and log" do
      subject { EmailParser::Base.new(invalid_email, log: log) }

      it "fails to parse and does not create a Customer record" do
        expect { subject.parse }.not_to change { Customer.count }
        expect(log.status).to eq("failure")
        expect(subject.success).to be false
        expect(subject.errors).not_to be_empty
      end
    end
  end

  describe "valid email and without log" do
    subject { EmailParser::Base.new(valid_email) }

    it "parses successfully and creates a Customer record" do
      expect { subject.parse }.to change { Customer.count }.by(1)
      expect(subject.success).to be true
      expect(subject.errors).to be_empty
    end
  end

  describe "invalid email and without log" do
    subject { EmailParser::Base.new(invalid_email) }

    it "fails to parse and does not create a Customer record" do
      expect { subject.parse }.not_to change { Customer.count }
      expect(subject.success).to be false
      expect(subject.errors).not_to be_empty
    end
  end

  describe "when customer is invalid" do
    subject { EmailParser::Base.new(valid_email, log: log) }

    it "populates errors when customer creation fails" do
      allow_any_instance_of(Customer).to receive(:save).and_return(false)

      subject.parse

      expect(subject.success).to be false
      expect(subject.errors).to include("Failed to create customer record")
      expect(log.status).to eq("failure")
    end
  end

  describe "when an exception occurs during parsing" do
    subject { EmailParser::Base.new(valid_email, log: log) }

    it "captures the exception and logs failure" do
      allow(subject).to receive(:set_fields).and_raise("Unexpected error")

      subject.parse

      expect(subject.success).to be false
      expect(subject.errors).to include(/Exception occurred: Unexpected error/)
      expect(log.status).to eq("failure")
    end
  end
end
