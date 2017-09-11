require 'time_util'

class User < ApplicationRecord
  include TimeUtil
  has_many :hands
  has_many :jankens, through: :hands

  validates :userid, uniqueness: true

  # 自分が参加した最新のじゃんけんのjid
  def last_jid
    jankens.maximum(:jid)
  end
  # jidで取得できるじゃんけんにおける自分の手
  # じゃんけんが存在しなければnil
  # 自分が参加していなければnil
  def my_hand(jid)
    hands.joins(:janken).where(jankens: { jid: jid }).first.try!(:value)
  end

  # q3: 勝ち数、q4: 負け数、q5: 引き分け数
  # v: 勝った手
  def set_result(v, jid)
    h = my_hand(jid)
    # 存在しないじゃんけんor自分が参加していないじゃんけんだった
    return unless h
    # あいこ（ちょきなし）
    if v == -1
      increment(:q5)
      save
      return
    end
    v == h ? increment(:q3) : increment(:q4)
    save
  end

  def do_janken(gcp)
    # じゃんけん時間ではないならnil
    return if current_jid.end_with?('--')
    # 対応するじゃんけんを取得（無ければ生成）
    janken = Janken.find_or_create_by(jid: current_jid)
    # 手を保存する。バリデーションに失敗すればfalse
    hand = hands.build(value: gcp)
    hand.janken = janken
    hand.save
  end

  # janken_and_yet : じゃんけん時間で、未じゃんけん
  # janken_and_done: じゃんけん時間で、じゃんけん済
  # result_and_yet : じゃんけん結果時間で、未じゃんけん
  # result_and_done: じゃんけん結果時間で、じゃんけん済
  def janken_status
    if janken_time?
      jid = current_jid
      return my_hand(jid) ? :janken_and_done : :janken_and_yet
    end
    jid = last_jid
    my_hand(jid) ? :result_and_done : :result_and_yet
  end
end
