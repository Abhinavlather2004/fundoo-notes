class Collaboration < ApplicationRecord
  belongs_to :user
  belongs_to :note
  validates :user_id, uniqueness: { scope: :note_id, message: "is already a collaborator" }
end
