class UserAnalytics
  attr_reader :user

  def initialize(user)
    @user = user
    @commitments = user.commitments
  end

  # --- Core Stats ---

  def total_count
    @total_count ||= @commitments.count
  end

  def completed_count
    @completed_count ||= @commitments.completed.count
  end

  def failed_count
    @failed_count ||= @commitments.failed.count
  end

  def active_count
    @active_count ||= @commitments.active.count
  end

  def completion_rate
    return 0 if resolved_count.zero?
    ((completed_count.to_f / resolved_count) * 100).round
  end

  def fail_rate
    return 0 if resolved_count.zero?
    ((failed_count.to_f / resolved_count) * 100).round
  end

  # --- Streak ---

  def current_streak
    commitments = @commitments.where.not(status: :active).order(updated_at: :desc)
    streak = 0
    commitments.each do |c|
      break unless c.completed?
      streak += 1
    end
    streak
  end

  def longest_streak
    commitments = @commitments.where.not(status: :active).order(updated_at: :asc)
    max = 0
    current = 0
    commitments.each do |c|
      if c.completed?
        current += 1
        max = current if current > max
      else
        current = 0
      end
    end
    max
  end

  # --- Category Analysis ---

  def worst_category
    failed = @commitments.failed.group(:category).count
    return nil if failed.empty?
    failed.max_by { |_, count| count }&.first
  end

  def best_category
    completed = @commitments.completed.group(:category).count
    return nil if completed.empty?
    completed.max_by { |_, count| count }&.first
  end

  def category_breakdown
    all = @commitments.group(:category).count
    completed = @commitments.completed.group(:category).count
    failed = @commitments.failed.group(:category).count

    all.map do |category, total|
      done = completed[category] || 0
      fail = failed[category] || 0
      rate = total > 0 ? ((done.to_f / total) * 100).round : 0
      { category: category, total: total, completed: done, failed: fail, rate: rate }
    end.sort_by { |c| c[:rate] }
  end

  # --- Time Pattern Analysis ---

  def failure_by_day_of_week
    return {} if @commitments.failed.empty?
    counts = @commitments.failed.group("EXTRACT(DOW FROM deadline)").count
    day_names = %w[Sun Mon Tue Wed Thu Fri Sat]
    counts.transform_keys { |k| day_names[k.to_i] }
  end

  def failure_by_hour
    return {} if @commitments.failed.empty?
    @commitments.failed.group("EXTRACT(HOUR FROM deadline)").count
      .transform_keys { |k| k.to_i }
  end

  def peak_failure_hour
    hours = failure_by_hour
    return nil if hours.empty?
    hour = hours.max_by { |_, count| count }.first
    format_hour(hour)
  end

  def peak_failure_day
    days = failure_by_day_of_week
    return nil if days.empty?
    days.max_by { |_, count| count }.first
  end

  # --- Procrastination Patterns ---

  def avg_completion_speed
    completed = @commitments.completed.where.not(completed_at: nil)
    return nil if completed.empty?
    total_hours = completed.sum do |c|
      ((c.completed_at - c.created_at) / 1.hour).round(1)
    end
    (total_hours / completed.count).round(1)
  end

  def last_minute_completions
    completed = @commitments.completed.where.not(completed_at: nil)
    return 0 if completed.empty?
    last_minute = completed.count { |c| (c.deadline - c.completed_at) < 1.hour }
    ((last_minute.to_f / completed.count) * 100).round
  end

  private

  def resolved_count
    completed_count + failed_count
  end

  def format_hour(hour)
    if hour == 0
      "12 AM"
    elsif hour < 12
      "#{hour} AM"
    elsif hour == 12
      "12 PM"
    else
      "#{hour - 12} PM"
    end
  end
end
