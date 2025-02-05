class Note < ApplicationRecord
  belongs_to :user
  validates :content, presence: true
  has_many :collaborations, dependent: :destroy
  has_many :collaborators, through: :collaborations, source: :user
  validates :color, format: { with: /\A#(?:[0-9a-fA-F]{3}){1,2}\z/, message: "must be a valid hex color" }

end
