class Customer < ApplicationRecord
  validates :name, :email, :telephone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  normalizes :email, with: ->(e) { e.strip.downcase }
end
