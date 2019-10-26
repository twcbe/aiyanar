class CreateEmergencyStatus < ActiveRecord::Migration[5.2]
  def change
    create_table :emergency_statuses do |t|
      t.boolean :active
      t.timestamps
    end
  end
end