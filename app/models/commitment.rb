class Commitment < ApplicationRecord
  belongs_to :user

  enum :status, { active: 0, completed: 1, failed: 2 }

  validates :title, presence: true
  validates :deadline, presence: true
  validates :category, presence: true
  validate :deadline_must_be_in_the_future, on: :create

  scope :past_deadline, -> { active.where(deadline: ...Time.current) }

  private

  def deadline_must_be_in_the_future
    if deadline.present? && deadline < 2.minutes.from_now
      errors.add(:deadline, "must be at least 2 minutes in the future. No time travel allowed.")
    end
  end
end
