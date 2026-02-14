class ExpireCommitmentsJob < ApplicationJob
  queue_as :default

  def perform
    Commitment.past_deadline.find_each do |commitment|
      commitment.update!(status: :failed)
    end
  end
end
