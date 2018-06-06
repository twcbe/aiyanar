CARD_READER_TOPIC = 'access_control/card_readers'
MQTT_BROKER_HOST = 'localhost'
MQTT_BROKER_PORT = 1883

Thread.new do

  mqtt_client = MqttClient.new(host = MQTT_BROKER_HOST, port = MQTT_BROKER_PORT)
  Rails.logger.info '[mqtt_handler] Connected to broker'

  mqtt_router = MqttRouter.new(CardHandler.new(mqtt_client))

  mqtt_client.subscribe_and_run CARD_READER_TOPIC do |_, payload|
    mqtt_router.handle payload
  end

end

