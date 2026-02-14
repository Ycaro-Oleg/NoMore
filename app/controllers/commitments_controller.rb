class CommitmentsController < ApplicationController
  before_action :set_commitment, only: [:show, :complete]

  def index
    @commitments = current_user.commitments.order(created_at: :desc)
  end

  def new
    @commitment = current_user.commitments.build
  end

  def create
    @commitment = current_user.commitments.build(commitment_params)

    if @commitment.save
      redirect_to root_path, notice: "Commitment created. The clock is ticking."
    else
      flash.now[:alert] = @commitment.errors.full_messages.join(". ")
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def complete
    if @commitment.active?
      @commitment.update!(status: :completed, completed_at: Time.current)
      redirect_to root_path, notice: "Done. One less excuse."
    else
      redirect_to root_path, alert: "This commitment can't be completed anymore."
    end
  end

  private

  def set_commitment
    @commitment = current_user.commitments.find(params[:id])
  end

  def commitment_params
    params.require(:commitment).permit(:title, :description, :category, :deadline)
  end
end
