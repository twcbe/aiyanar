class MqttRouter

  def initialize(message_handler)
    @message_handler = message_handler
  end

  def handle(payload)
    Rails.logger.info "[mqtt_handler] Processing message: #{payload}"
    begin
      payload = JSON.parse(payload)
      message_type = payload['message']
      @message_handler.send(message_type, payload) if !message_type.nil? && @message_handler.respond_to?(message_type)
    rescue JSON::ParserError => _
      Rails.logger.info "[mqtt_handler] unknown message or unable to parse as JSON; Ignoring."
    ensure
      Rails.logger.info "[mqtt_handler] End processing"
    end
  end

end