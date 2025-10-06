class Customer < ApplicationRecord
  validates :name, :phone, :email, :product_code, :email_subject, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
