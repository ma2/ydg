class Hand < ApplicationRecord
  belongs_to :janken
  belongs_to :user

  validates :user_id, uniqueness: { scope: :janken_id, message: 'じゃんけんに参加できるのは一度だけです' }
end
