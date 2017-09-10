require 'rails_helper'

RSpec.describe Hand, :type => :model do
  fixtures :all
  describe 'バリデーション' do
    it 'ひとつのじゃんけんに対して、一人のユーザは一つの手しか持てないこと' do
      # u01はjk01に参加済み
      janken = jankens(:jk01)
      user = users(:u01)
      hand = user.hands.build(value: 0)
      hand.janken = janken
      expect(hand.save).not_to be
    end
  end
end