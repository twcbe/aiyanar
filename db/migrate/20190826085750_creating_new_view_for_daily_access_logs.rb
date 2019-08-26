class CreatingNewViewForDailyAccessLogs < ActiveRecord::Migration[5.2]
  def down
  end

  def up
    execute <<-SQL
drop view daily_access_logs;
SQL
    execute <<-SQL
CREATE VIEW daily_access_logs as SELECT date(access_logs.created_at) date, room_id, user_id, max(card_number) card_number,
min(CASE WHEN direction = 'enter' THEN access_logs.created_at ELSE null END) first_enter,
max(CASE WHEN direction = 'enter' THEN access_logs.created_at ELSE null END) last_enter,
min(CASE WHEN direction = 'exit' THEN access_logs.created_at ELSE null END) first_exit,
max(CASE WHEN direction = 'exit' THEN access_logs.created_at ELSE null END) last_exit
FROM access_logs JOIN locks on access_logs.lock_id = locks.id
WHERE user_id is not null
GROUP BY user_id, room_id, date(access_logs.created_at);
SQL
  end
end
