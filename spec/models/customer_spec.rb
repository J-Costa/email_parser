require 'rails_helper'

RSpec.describe Customer, type: :model do
  context 'validations' do
    it 'is valid with valid attributes' do
      customer = Customer.new(
        name: 'John Doe',
        phone: '123-456-7890',
        email: 'john.doe@example.com',
        product_code: 'PROD123',
        email_subject: 'Hello'
      )
      expect(customer).to be_valid
    end

    it 'is invalid without a name' do
      customer = Customer.new(name: nil)
      expect(customer).to be_invalid
    end

    it 'is invalid without a phone number' do
      customer = Customer.new(phone: nil)
      expect(customer).to be_invalid
    end

    it 'is invalid without an email' do
      customer = Customer.new(email: nil)
      expect(customer).to be_invalid
    end

    it 'is invalid without a product code' do
      customer = Customer.new(product_code: nil)
      expect(customer).to be_invalid
    end

    it 'is invalid without an email subject' do
      customer = Customer.new(email_subject: nil)
      expect(customer).to be_invalid
    end

    it "is invalid with an improperly formatted email" do
      customer = Customer.new(email: 'invalid_email')
      expect(customer).to be_invalid
    end
  end
end
