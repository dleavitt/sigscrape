module RoundTime
  def round_off(seconds = 60)
    Time.at((self.to_f / seconds).round * seconds)
  end

  def floor(seconds = 60)
    Time.at((self.to_f / seconds).floor * seconds)
  end

  def week_day?
    ! self.sunday? && ! self.saturday?
  end
end

Time.send(:include, RoundTime)
DateTime.send(:include, RoundTime)
