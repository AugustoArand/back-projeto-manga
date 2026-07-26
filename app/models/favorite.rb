class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :manga, optional: true

  validates :title, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
