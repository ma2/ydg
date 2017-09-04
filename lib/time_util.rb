module TimeUtil

  # 0～15分、30～45分
  def janken_time?
    min = Time.current.min
    (min >= 0 && min < 15) || (min >= 30 && min < 45)
  end

  def janken_result_time?
    ! janken_time?
  end

  # 次のじゃんけん開始時間
  def next_janken_time
    tm = Time.current
    min = tm.min
    return "#{tm.hour}:30" if min >= 0 && min < 30
    "#{tm.hour+1}:00"
  end

  # 次のじゃんけん結果発表時間
  def next_result_time
    tm = Time.current
    min = tm.min
    return "#{tm.hour}:15" if min >= 0 && min < 15
    return "#{tm.hour}:45" if min >= 15 && min < 45
    "#{tm.hour+1}:15"
  end

  # 最後のじゃんけんid
  def last_jid
    tm = Time.current.strftime('%Y%m%d%H')
    min = (tm.min >= 0 && tm.min < 30) ? '00' : '30'
    tm + min
  end

  # 今のじゃんけんid
  def current_jid
    tm = Time.current
    min = '--'
    min = '00' if (tm.min >= 0 && tm.min < 15)
    min = '30' if (tm.min >= 30 && tm.min < 45)
    tm.strftime("%Y%m%d%H#{min}")
  end
end
