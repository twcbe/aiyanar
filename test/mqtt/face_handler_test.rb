require './test/test_helper'

class FaceHandlerTest < ActiveSupport::TestCase

  test 'face handler should handle messages and allow access for authorized employees' do
    mqtt_client = Minitest::Mock.new
    mqtt_client.expect(:publish, nil, ['access_control/server', {command: 'open_door', duration: 5, beeps: 1, beep_duration: 200, lock_name: 'Main door'}.to_json])

    employee = Role.create!(name: 'Employee')
    employee_id = 1234
    user = User.create!(employee_id: employee_id, name: 'test user', roles: [employee], enabled: true)
    main_door = Lock.create!(name: 'Main door')
    Permission.create!(role: employee, lock: main_door)

    message = {
        'source' => 'Main door:enter',
        'employee_id' => employee_id
    }
    face_handler = FaceHandler.new(mqtt_client)
    face_handler.process(message)

    assert_mock mqtt_client
  end

  test 'face handler should handle messages and deny access for unauthorized employees' do
    mqtt_client = Minitest::Mock.new
    mqtt_client.expect(:publish, nil, ['access_control/server', {command: 'deny_access', beeps: 2, beep_duration: 100, lock_name: 'Main door'}.to_json])

    message = {
        'source' => 'Main door:enter',
        'employee_id' => 1234
    }
    face_handler = FaceHandler.new(mqtt_client)
    face_handler.process(message)

    assert_mock mqtt_client
  end

  test 'face handler should ignore invalid messages with missing employee id or source' do
    mqtt_client = Minitest::Mock.new

    face_handler = FaceHandler.new(mqtt_client)

    message = {'employee_id' => 1234}
    face_handler.process(message)

    message = {'source' => 'Main door:enter'}
    face_handler.process(message)

    assert_mock mqtt_client
  end

  test 'face handler should ignore invalid messages with missing lock_name field' do
    mqtt_client = Minitest::Mock.new

    message = {
        'source' => ':enter',
        'employee_id' => 1234
    }
    face_handler = FaceHandler.new(mqtt_client)
    face_handler.process(message)

    assert_mock mqtt_client
  end

  test 'face handler should ignore invalid messages with missing direction field' do
    mqtt_client = Minitest::Mock.new

    message = {
        'source' => 'Main door:',
        'employee_id' => 1234
    }
    face_handler = FaceHandler.new(mqtt_client)
    face_handler.process(message)

    assert_mock mqtt_client
  end
end
