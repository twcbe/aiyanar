class AccessManager
  private
  def is_card_valid(card)
    !card.nil?
  end

  def is_user_valid(user)
    !user.nil?
  end

  def is_card_assigned_to_user(card)
    !card.user.nil?
  end

  def is_lock_valid(lock)
    !lock.nil?
  end

  def has_permission(lock, roles)
    permission = Permission.where({lock: lock, role: roles}).first
    !permission.nil?
  end
end
