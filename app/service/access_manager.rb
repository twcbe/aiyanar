class AccessManager
  def self.authorize(card_number, lock_name)
    card = Card.where({card_number: card_number}).first
    lock = Lock.where({name: lock_name}).first
    return is_card_valid(card) && is_card_assigned_to_user(card) && is_lock_valid(lock) && has_permission(lock, card.user.roles)
  end

  private

  def self.has_permission(lock, roles)
    permission = Permission.where({lock:lock, role:roles}).first
    !permission.nil?
  end

  def self.is_lock_valid(lock)
    !lock.nil?
  end

  def self.is_card_assigned_to_user(card)
    !card.user.nil?
  end

  def self.is_card_valid(card)
    !card.nil?
  end
end
