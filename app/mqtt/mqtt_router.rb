class MqttRouter

  def initialize(handlers = {})
    @handlers = handlers
  end

  def handle(topic, payload)
    Rails.logger.info "[mqtt_handler] Processing message: #{payload}"
    begin
      handler = @handlers[topic]
      handler.process JSON.parse(payload)
    rescue JSON::ParserError => _
      Rails.logger.info "[mqtt_handler] Unable to parse as JSON; Ignoring #{payload}"
    rescue RuntimeError => _
      Rails.logger.info "[mqtt_handler] Unknown message; Ignoring #{payload}"
    ensure
      Rails.logger.info "[mqtt_handler] End processing"
    end
  end


end
