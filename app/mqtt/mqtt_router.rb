class MqttRouter

  def initialize(message_handler)
    @message_handler = message_handler
  end

  def handle(payload)
    Rails.logger.info "[mqtt_handler] Processing message: #{payload}"
    payload = JSON.parse(payload)
    @message_handler.send(payload['message'].to_sym, payload)
    Rails.logger.info "[mqtt_handler] End processing"
  end

end