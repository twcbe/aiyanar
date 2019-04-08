class CreateDailyAccessLogView < ActiveRecord::Migration[5.2]
 def down
    execute <<-SQL
      drop view daily_access_logs
    SQL
  end

  def up
    execute <<-SQL
CREATE VIEW daily_access_logs as SELECT date(created_at) date, lock_id, user_id, max(card_number) card_number,
min(CASE WHEN direction = 'enter' THEN created_at ELSE null END) first_enter,
max(CASE WHEN direction = 'enter' THEN created_at ELSE null END) last_enter,
min(CASE WHEN direction = 'exit' THEN created_at ELSE null END) first_exit,
max(CASE WHEN direction = 'exit' THEN created_at ELSE null END) last_exit
FROM access_logs
WHERE user_id is not null
GROUP BY user_id, lock_id, date(created_at)
SQL
  end
end
