class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.numeric :card_id
      t.numeric :user_id

      t.timestamps
    end
  end
end
