class MqttClient

  def initialize(host = 'localhost', port = 1883)
    @port = port
    @host = host
    @client = MQTT::Client.connect(host: host, port: port)
  end

  def publish(topic, message)
    @client.publish topic, message
  end

  # blocking call, won't return unless an exception occurred
  def subscribe_and_run(topic, &block)
    @client.subscribe(topic)
    @client.get &block
  end

end