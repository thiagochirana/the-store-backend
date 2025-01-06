class User < ApplicationRecord
  has_secure_password
  enum :role, shopowner: "shopowner", salesperson: "salesperson", prefix: :is

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  normalizes :email, with: ->(e) { e.strip.downcase }
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validate :password_does_not_contain_invalid_characters

  private

  def password_present?
    password.present?
  end

  def password_does_not_contain_invalid_characters
    if password =~ /\s/
      errors.add(:password, "não pode conter espaços")
    end

    if password =~ /[áàãâäéèêëíìîïóòôõöúùûüçÇ]/
      errors.add(:password, "não pode conter acentos ou caracteres especiais como Ç")
    end
  end
end
