require 'time_util'
include TimeUtil

class Janken < ApplicationRecord

  has_many :hands
  has_many :users, through: :hands

  validates :jid, uniqueness: true

  # ユーザの中でじゃんけんに参加している人の勝敗を計算する
  # TODO: aggregateがnilのじゃんけんを全て集計する
  def self.aggregate(jid=nil)
    # じゃんけんを取得
    janken = find_by(jid: jid || last_jid)
    # 対応するじゃんけんがなかった
    return unless janken
    return if janken.aggregated
    v = janken.victory
    unless v
      # 参加人数がひとり以下
      janken.update(aggregated: true)
      return
    end
    # ユーザの勝ち負け数を設定する
    User.all.each do |user|
      user.set_result(v, last_jid)
    end
    # 集計処理完了
    janken.update(aggregated: true)
  end

  # 結果報告（ぐー、ちょき、ぱーがいくつずつだったか）
  # self.aggregateが終わっている必要がある
  def self.result(jid = nil)
    janken = find_by(jid: jid || last_jid)
    return unless janken
    gcp_h = janken.hands.group(:value).count
    gcp_h['v'] = janken.victory
    gcp_h
  end

  # じゃんけんで勝った手
  def victory
    # 誰も参加して無ければnil
    return if hands.count <= 1
    gcp = hands.order(:value).pluck(:value).uniq
    return 1 if gcp == [0, 1, 2] || gcp == [1, 2]
    return 2 if gcp == [0, 2]
    return 0 if gcp == [0, 1]
    # ちょきのないあいこ
    -1
  end

end
