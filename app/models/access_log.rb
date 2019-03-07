class AccessLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :lock
  # belongs_to :card, foreign_key: :card_number, optional: true

  enum direction: {
      enter: 'enter',
      exit: 'exit'
  }

  def self.recent_logs_for_user(user, count)
    AccessLog.where(user_id: user.id).order(:created_at).reverse_order.limit(count)
  end

  def self.recent_logs_for_card_number(card_number, count)
    AccessLog.where(card_number: card_number).order(:created_at).reverse_order.limit(count)
  end

  def self.recent_logs_for_lock(lock, count)
    AccessLog.where(lock_id: lock.id).order(:created_at).reverse_order.limit(count)
  end

  def self.latest_for_users_currently_behind(lock)
    AccessLog.where('user_id is not null').where(lock_id: lock.id).group('user_id').having('MAX(ROWID)').order('ROWID').to_a.select do |access_log|
      access_log.direction == 'enter'
    end
  end

  def self.fist_in_last_out_entries_per_day(lock)
    AccessLog.select("date(created_at) date, lock_id, user_id, max(card_number) card_number, min(CASE WHEN direction = 'enter' THEN created_at ELSE null END) \"first_enter\", max(CASE WHEN direction = 'enter' THEN created_at ELSE null END) \"last_enter\", min(CASE WHEN direction = 'exit' THEN created_at ELSE null END) \"first_exit\", max(CASE WHEN direction = 'exit' THEN created_at ELSE null END) \"last_exit\"")
    .where("user_id is not null")
    .where(lock_id: lock.id)
    .group("user_id, lock_id, date(created_at)")
  end
end
