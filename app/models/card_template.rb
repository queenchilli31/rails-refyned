class CardTemplate < ApplicationRecord
  has_many :cards, dependent: :destroy

  validates :name, presence: true
end
