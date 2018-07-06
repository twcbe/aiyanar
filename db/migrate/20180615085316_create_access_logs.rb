class CreateAccessLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :access_logs do |t|
      t.references :lock, foreign_key: true, null: false
      t.string :card_number, null: false
      t.references :user, foreign_key: true
      t.string :direction, null: false
      t.boolean :access_provided, null: false

      t.timestamps
    end
  end
end
