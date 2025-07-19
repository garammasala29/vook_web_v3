class Shop < ApplicationRecord
  has_many :image_credits, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
