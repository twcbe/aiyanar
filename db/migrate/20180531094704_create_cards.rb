class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.string :card_number, index: {unique: true}
      t.boolean :enabled, null: false, default: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
