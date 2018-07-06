require './test/test_helper'

class CardHandlerTest < ActiveSupport::TestCase

  test 'card handler should handle card read message and allow access for authorized card' do
    mqtt_client = Minitest::Mock.new
    mqtt_client.expect(:publish, nil, ['access_control/server', {command: 'open_door', duration: 5, beep_tone: 'twice', lock_name: 'Main door'}.to_json])

    security = Role.create!(name: 'Security')
    user = User.create!(name: 'test user', roles: [security], enabled: true)
    Card.create!(card_number: 'ABCDEF', user: user, enabled: true)
    main_door = Lock.create!(name: 'Main door')
    Permission.create!(role: security, lock: main_door)

    message = {
        'message' => 'card_read',
        'card_number' => 'ABCDEF',
        'lock_name' => 'Main door',
        'direction' => 'enter'
    }
    card_handler = CardHandler.new(mqtt_client)
    card_handler.card_read(message)

    assert_mock mqtt_client
  end

  test 'card handler should handle card read message and deny access for unauthorized card' do
    mqtt_client = Minitest::Mock.new
    mqtt_client.expect(:publish, nil, ['access_control/server', {command: 'deny_access', beep_tone: 'something', feedback_led: 'toggle_twice'}.to_json])

    message = {
        'message' => 'card_read',
        'card_number' => 'ABCDEF',
        'lock_name' => 'Main door',
        'direction' => 'enter'
    }
    card_handler = CardHandler.new(mqtt_client)
    card_handler.card_read(message)

    assert_mock mqtt_client
  end

  test 'card handler should ignore invalid messages with missing card_number field' do
    mqtt_client = Minitest::Mock.new

    message = {
        'message' => 'card_read',
        'lock_name' => 'Main door',
        'direction' => 'enter'
    }
    card_handler = CardHandler.new(mqtt_client)
    card_handler.card_read(message)

    assert_mock mqtt_client
  end

  test 'card handler should ignore invalid messages with missing lock_name field' do
    mqtt_client = Minitest::Mock.new

    message = {
        'message' => 'card_read',
        'card_number' => 'ABCDEF',
        'direction' => 'enter'
    }
    card_handler = CardHandler.new(mqtt_client)
    card_handler.card_read(message)

    assert_mock mqtt_client
  end

  test 'card handler should ignore invalid messages with missing direction field' do
    mqtt_client = Minitest::Mock.new

    message = {
        'message' => 'card_read',
        'card_number' => 'ABCDEF',
        'lock_name' => 'Main door'
    }
    card_handler = CardHandler.new(mqtt_client)
    card_handler.card_read(message)

    assert_mock mqtt_client
  end

end