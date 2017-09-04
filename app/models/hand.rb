class Hand < ApplicationRecord
  belongs_to :janken
  belongs_to :user
end
