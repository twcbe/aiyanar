class CardAccessManager < AccessManager
  def initialize(card_number, lock_name, direction)
    @card_number = card_number
    @card = Card.where({card_number: card_number}).first
    @lock = Lock.where({name: lock_name}).first
    @direction = direction
  end

  def process
    access_allowed = is_card_valid(@card) && @card.enabled && is_card_assigned_to_user(@card) && @card.user.enabled && is_lock_valid(@lock) && has_permission(@lock, @card.user.roles)
    AccessLog.create!({
                          lock_id: @lock.try(:id),
                          card_number: @card_number,
                          access_method: 'access_card',
                          user_id: @card.try(:user).try(:id),
                          direction: @direction,
                          access_provided: access_allowed}) unless @lock.try(:id).nil? || @card_number.nil?
    access_allowed
  end
end
