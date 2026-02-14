class CreateFocusSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :focus_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :duration_seconds

      t.timestamps
    end
  end
end
