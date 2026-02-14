class ConfrontationalMessages
  def initialize(analytics)
    @analytics = analytics
  end

  def dashboard_greeting
    return "First time here? Make a commitment. See if you can keep it." if @analytics.total_count.zero?
    return "You haven't kept a single commitment yet. Not one." if @analytics.completed_count.zero? && @analytics.failed_count > 0

    if @analytics.current_streak >= 5
      "#{@analytics.current_streak} in a row. Don't get comfortable — that's when you slip."
    elsif @analytics.current_streak >= 3
      "Streak of #{@analytics.current_streak}. Prove it's not a fluke."
    elsif @analytics.fail_rate > 60
      "#{@analytics.fail_rate}% failure rate. At some point this stops being bad luck."
    elsif @analytics.fail_rate > 40
      "Almost half your commitments fail. You already know why."
    elsif @analytics.last_minute_completions > 50
      "#{@analytics.last_minute_completions}% of your completions are last-minute. That's not discipline — that's panic."
    elsif @analytics.completion_rate > 80
      "#{@analytics.completion_rate}% completion. You're proving something. Keep going."
    else
      "Your commitments are waiting. No one else is going to do them."
    end
  end

  def on_commitment_created
    [
      "Clock's ticking. No extensions.",
      "Committed. Now prove it wasn't just words.",
      "Another promise. Let's see if this one sticks.",
      "The deadline is set. No negotiating with yourself.",
      "You said it. Now do it."
    ].sample
  end

  def on_commitment_completed
    if @analytics.current_streak >= 5
      "#{@analytics.current_streak} streak. You're building something."
    elsif @analytics.current_streak >= 3
      "That's #{@analytics.current_streak} in a row. Don't stop now."
    else
      [
        "Done. One less excuse.",
        "Kept your word. That's the minimum.",
        "Completed. Don't celebrate — it's what you were supposed to do.",
        "Done. Now make another one."
      ].sample
    end
  end

  def on_commitment_failed
    [
      "You chose comfort over commitment.",
      "Another broken promise. To yourself.",
      "You had time. You had the ability. You chose not to.",
      "This is now part of your permanent record.",
      "Failed. Not because you couldn't — because you didn't."
    ].sample
  end

  def category_callout(category)
    return nil unless category
    rate = category_fail_rate(category)
    return nil if rate.nil? || rate < 30

    if rate > 70
      "You've failed #{rate}% of your #{category} commitments. Either commit for real or stop pretending."
    elsif rate > 50
      "#{category.capitalize} is where your discipline breaks down. You know this."
    else
      "#{category.capitalize} is becoming a weak spot. #{rate}% failure rate."
    end
  end

  def streak_message
    streak = @analytics.current_streak

    if streak.zero? && @analytics.failed_count > 0
      "Streak: 0. Your last commitment was a failure."
    elsif streak.zero?
      "No streak yet. Start one."
    elsif streak >= 10
      "#{streak} commitments kept. This is who you're becoming."
    elsif streak >= 5
      "#{streak} streak. One failure resets everything."
    elsif streak >= 3
      "#{streak} in a row. Fragile. Keep going."
    else
      "Streak: #{streak}."
    end
  end

  private

  def category_fail_rate(category)
    breakdown = @analytics.category_breakdown
    cat = breakdown.find { |c| c[:category] == category }
    return nil unless cat && cat[:total] >= 2
    100 - cat[:rate]
  end
end
