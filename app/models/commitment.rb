class Commitment < ApplicationRecord
  belongs_to :user

  enum :status, { active: 0, completed: 1, failed: 2 }

  validates :title, presence: true
  validates :deadline, presence: true
  validates :category, presence: true
  validate :deadline_must_be_in_the_future, on: :create

  private

  def deadline_must_be_in_the_future
    if deadline.present? && deadline <= Time.current
      errors.add(:deadline, "can't be in the past. No time travel allowed.")
    end
  end

  scope :past_deadline, -> { active.where(deadline: ...Time.current) }
end
