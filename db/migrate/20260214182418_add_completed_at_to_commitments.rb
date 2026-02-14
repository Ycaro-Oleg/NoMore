class AddCompletedAtToCommitments < ActiveRecord::Migration[8.1]
  def change
    add_column :commitments, :completed_at, :datetime
  end
end
