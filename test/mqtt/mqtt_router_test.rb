require './test/test_helper'

class MqttRouterTest < ActiveSupport::TestCase

  test 'mqtt router should route given message to corresponding method in message_handler' do
    message_handler = Minitest::Mock.new
    message_handler.expect(:card_read, nil, [{'message' => 'card_read', 'some_field' => 'some value', 'value' => 3}])

    message = '{"message":"card_read", "some_field": "some value", "value": 3}'
    mqtt_router = MqttRouter.new(message_handler)
    mqtt_router.handle(message)

    assert_mock message_handler

    message_handler = Minitest::Mock.new
    message_handler.expect(:some_message, nil, [{'message' => 'some_message', 'other_field' => 'other value'}])

    message = '{"message":"some_message", "other_field": "other value"}'
    mqtt_router = MqttRouter.new(message_handler)
    mqtt_router.handle(message)

    assert_mock message_handler

  end

end
