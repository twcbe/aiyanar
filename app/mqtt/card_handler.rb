class CardHandler
  SERVER_TOPIC = 'access_control/server'

  def initialize(mqtt_client)
    @mqtt_client = mqtt_client
  end

  def card_read(message)
    return if message['card_number'].blank? || message['lock_name'].blank? || message['direction'].blank?
    is_access_allowed = CardAccessManager.new(message['card_number'], message['lock_name'], message['direction']).process
    if is_access_allowed
      Rails.logger.info "[card_handler] Provided access to card number #{message['card_number']}, assigned to some user"
      payload = {command: 'open_door', duration: 3, beeps: 0, lock_name: message['lock_name']}.to_json
    else
      Rails.logger.info "[card_handler] Denied access to card number #{message['card_number']}"
      payload = {command: 'deny_access', beeps: 2, beep_duration: 100}.to_json
    end
    @mqtt_client.publish(SERVER_TOPIC, payload)
    Rails.logger.info "[card_handler] sending message: #{payload}"
    ActionCable.server.broadcast 'card_read_messages',
                                 card_number: message['card_number'],
                                 lock: message['lock_name']
  end

  def process(payload)
    message_type = payload['message']
    raise RuntimeError.new('Invalid message') if message_type.nil? || !self.respond_to?(message_type)
    self.send(message_type, payload)
  end
end
