class InsightsController < ApplicationController
  def show
    @analytics = ::UserAnalytics.new(current_user)
  end
end
