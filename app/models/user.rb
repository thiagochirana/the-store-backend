class User < ApplicationRecord
  has_secure_password

  has_one :commission, dependent: :destroy
  has_many :salespersons, class_name: "User", foreign_key: "shopowner_id", dependent: :destroy
  belongs_to :shopowner, class_name: "User", optional: true
  has_many :payments

  enum :role, shopowner: "shopowner", salesperson: "salesperson", prefix: :is

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: true
  normalizes :email, with: ->(e) { e.strip.downcase }
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validate :password_does_not_contain_spaces
  validate :password_does_not_contain_invalid_chars

  after_create :generate_commission

  def generate_commission
    Commission.create(user: self)
  end

  def password_present?
    password.present?
  end

  def password_does_not_contain_spaces
    if password =~ /\s/
      errors.add(:password, "não pode conter espaços")
    end
  end

  def password_does_not_contain_invalid_chars
    if password =~ /[áàãâäéèêëíìîïóòôõöúùûüçÇ]/
      errors.add(:password, "não pode conter acentos ou caracteres especiais como Ç")
      true
    end
  end
end
