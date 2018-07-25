class AddAccessMethodToAccessLog < ActiveRecord::Migration[5.2]
  def change
    add_column :access_logs, :access_method, :string, default: 'access_card', null: false
    change_column :access_logs, :card_number, :string, null: true
  end
end
