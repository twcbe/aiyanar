class AddRoomRefToLocks < ActiveRecord::Migration[5.2]
  def change
    add_reference :locks, :room, foreign_key: true
  end
end
