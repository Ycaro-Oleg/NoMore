class CreateCommitments < ActiveRecord::Migration[8.1]
  def change
    create_table :commitments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :category
      t.datetime :deadline
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :commitments, [:user_id, :status]
    add_index :commitments, [:deadline, :status]
  end
end
