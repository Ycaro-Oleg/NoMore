class FocusSessionsController < ApplicationController
  def index
    @sessions = current_user.focus_sessions.order(created_at: :desc).limit(20)
    @active_session = current_user.focus_sessions.where(ended_at: nil).last
  end

  def create
    # Stop any existing active session first
    current_user.focus_sessions.where(ended_at: nil).update_all(
      ended_at: Time.current,
      duration_seconds: Arel.sql("EXTRACT(EPOCH FROM NOW() - started_at)::integer")
    )

    @session = current_user.focus_sessions.create!(started_at: Time.current)

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace("focus-controls",
          partial: "focus_sessions/controls",
          locals: { active_session: @session })
      }
      format.html { redirect_to focus_sessions_path }
    end
  end

  def stop
    @session = current_user.focus_sessions.find(params[:id])
    @session.update!(
      ended_at: Time.current,
      duration_seconds: (Time.current - @session.started_at).to_i
    )

    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: [
          turbo_stream.replace("focus-controls",
            partial: "focus_sessions/controls",
            locals: { active_session: nil }),
          turbo_stream.prepend("session-history",
            partial: "focus_sessions/session_row",
            locals: { session: @session })
        ]
      }
      format.html { redirect_to focus_sessions_path, notice: "Session recorded. #{@session.duration_seconds / 60} minutes of focus." }
    end
  end
end
