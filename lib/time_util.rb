module TimeUtil

  # 0～15分、30～45分
  def janken_time?
    min = Time.current.min
    (min >= 0 && min < 15) || (min >= 30 && min <= 59)
  end

  def janken_result_time?
    ! janken_time?
  end

end
