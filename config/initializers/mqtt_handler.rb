CARD_READER_TOPIC = 'access_control/card_readers'
FACE_RECOGNITION_TOPIC = 'face_recognition'
EMERGENCY_TOPIC = 'access_control/server'
MQTT_BROKER_HOST = ENV["MQTT_HOST"] || Settings.mqtt_host
MQTT_BROKER_PORT = ENV["MQTT_PORT"] || Settings.mqtt_port

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

    topic_handlers = {CARD_READER_TOPIC => CardHandler.new(mqtt_client), FACE_RECOGNITION_TOPIC => FaceHandler.new(mqtt_client), EMERGENCY_TOPIC => EmergencyStatusHandler.new(mqtt_client)}
    mqtt_router = MqttRouter.new(topic_handlers)

    topic_handlers.keys.each do |topic|
      mqtt_client.subscribe topic
    end

    mqtt_client.get do |topic, payload|
      log_and_ignore_exception do
        mqtt_router.handle topic, payload
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

