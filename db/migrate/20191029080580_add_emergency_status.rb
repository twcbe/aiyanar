class AddEmergencyStatus < ActiveRecord::Migration[5.2]
  def change
        add_column :emergency_statuses, :startTime, :string
        add_column :emergency_statuses, :endTime, :string
  end
end