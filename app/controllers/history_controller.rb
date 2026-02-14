class HistoryController < ApplicationController
  def show
    @commitments = current_user.commitments.order(created_at: :desc)
    @analytics = ::UserAnalytics.new(current_user)
  end
end
