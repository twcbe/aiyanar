require './test/test_helper'

class MqttRouterTest < ActiveSupport::TestCase

  test 'mqtt router should route the given message to the handler corresponding to the topic for processing' do
    message_handler = Minitest::Mock.new
    another_handler = Minitest::Mock.new
    message_handler.expect(:process, nil, [{'message' => 'card_read', 'some_field' => 'some value', 'value' => 3}])

    message = '{"message":"card_read", "some_field": "some value", "value": 3}'
    mqtt_router = MqttRouter.new({'some_topic' => message_handler, 'some_other_topic' => another_handler})
    mqtt_router.handle('some_topic', message)

    assert_mock message_handler
    assert_mock another_handler
  end

  test 'mqtt router should not throw exception if the given message is not json' do
    message_handler = Minitest::Mock.new

    def message_handler.card_read(_)
      raise NoMethodError, "Unexpected call. card_read expected not to be called"
    end

    message = 'some non-json message'
    mqtt_router = MqttRouter.new({'some_topic' => message_handler})
    mqtt_router.handle('some_topic', message)

    assert_mock message_handler
  end

  test 'mqtt router should not throw exception if the given message is unknown to the message handler' do
    message_handler = CardHandler.new(Minitest::Mock.new)

    message = '{"message":"unknown_message_name", "other_field": "other value"}'
    mqtt_router = MqttRouter.new({'some_topic' => message_handler})
    mqtt_router.handle('some_topic', message)
  end

end
