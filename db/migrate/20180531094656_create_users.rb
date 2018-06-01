class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.integer :employee_id, index: {unique: true}
      t.string :name, :null => false

      t.timestamps
    end
  end
end
