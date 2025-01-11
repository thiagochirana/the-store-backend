class Commission < ApplicationRecord
  belongs_to :user
  validates :percentage, presence: true, numericality: { greater_than: 0 }
end
