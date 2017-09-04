require 'time_util'

class User < ApplicationRecord
  include TimeUtil
  has_many :hands
  has_many :jankens, through: :hands

  # jidで取得できるじゃんけんにおける自分の手
  def my_hand(jid)
    hands.joins(:janken).where(jankens: { jid: jid }).first.value
  end

  # q3: 勝ち数、q4: 負け数、q5: 引き分け数
  # q2: 自分の手、v: 勝った手
  def set_result(v, jid)
    # 引き分け
    if v == 0
      increment(:q5)
      return
    end
    h = my_hand(jid)
    v == h ? increment(:q3) : increment(:q4)
  end

  def do_janken(gcp)
    # じゃんけん時間ではない
    return if current_jid.end_with?('--')
    # 対応するじゃんけんを取得（無ければ生成）
    janken = Janken.find_or_create_by(jid: current_jid)
    hand = hands.build(value: gcp)
    hand.janken = janken
    hand.save
  end
end
