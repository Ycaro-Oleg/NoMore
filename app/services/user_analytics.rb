class UserAnalytics
  attr_reader :user

  def initialize(user)
    @user = user
    @commitments = user.commitments
  end

  def total_count
    @commitments.count
  end

  def completed_count
    @commitments.completed.count
  end

  def failed_count
    @commitments.failed.count
  end

  def completion_rate
    return 0 if total_count.zero?
    ((completed_count.to_f / total_count) * 100).round
  end

  def fail_rate
    return 0 if total_count.zero?
    ((failed_count.to_f / total_count) * 100).round
  end

  def current_streak
    completed = @commitments.completed.order(completed_at: :desc)
    streak = 0
    completed.each do |c|
      break if c.completed_at.nil?
      streak += 1
    end
    streak
  end

  def worst_category
    failed = @commitments.failed.group(:category).count
    return nil if failed.empty?
    failed.max_by { |_, count| count }&.first
  end
end
