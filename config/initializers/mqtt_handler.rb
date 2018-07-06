CARD_READER_TOPIC = 'access_control/card_readers'
MQTT_BROKER_HOST = '10.137.120.19'
MQTT_BROKER_PORT = 1883

def log_and_ignore_exception
  begin
    yield
  rescue Exception => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    # ignored
  end
end

class MqttHandler
  def run
    mqtt_client = MqttClient.new(host = MQTT_BROKER_HOST, port = MQTT_BROKER_PORT)
    Rails.logger.info '[mqtt_handler] Connected to broker'

    mqtt_router = MqttRouter.new(CardHandler.new(mqtt_client))

    mqtt_client.subscribe_and_run CARD_READER_TOPIC do |_, payload|
      log_and_ignore_exception do
        mqtt_router.handle payload
      end
    end
  end
end

Thread.new do
  while true
    Rails.logger.info '[mqtt_handler] Starting up'
    log_and_ignore_exception do
      MqttHandler.new.run
    end
    Rails.logger.info '[mqtt_handler] Restarting due to previous exception'
  end
end

