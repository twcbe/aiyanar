require './test/test_helper'

class EmployeeAccessManagerTest < ActiveSupport::TestCase
  test 'access manager should give access to valid employees if the employee is enabled and has permission for given lock and log the access' do
    employee_id = '12345'
    lock_name = 'Main door'
    direction = 'enter'
    normal_user_role = Role.create!(name: 'Normal user')
    user = User.create!(employee_id: employee_id, name: 'test user', roles: [normal_user_role], enabled: true)
    main_door_lock = Lock.create!(name: lock_name)
    Permission.create!(role: normal_user_role, lock: main_door_lock)

    assert_equal(true, EmployeeAccessManager.new(employee_id, lock_name, direction).process)
    assert_equal(1, AccessLog.where({lock_id: main_door_lock.id, access_method: 'face_recognition', user_id: user.id, direction: direction, access_provided: true}).size)
  end

  test 'access manager should deny access to unauthorized employee and log the attempt' do
    employee_id = '12345'
    direction = 'enter'
    lock_name = 'Main door'
    normal_user_role = Role.create!(name: 'Normal user')
    user = User.create!(employee_id: employee_id, name: 'test user', roles: [normal_user_role], enabled: false)
    main_door_lock = Lock.create!(name: lock_name)
    assert_equal(false, EmployeeAccessManager.new(employee_id, lock_name, direction).process)
    assert_equal(1, AccessLog.where({lock_id: main_door_lock.id, access_method: 'face_recognition', user_id: user.id, direction: direction, access_provided: false}).size)
  end

  test 'access manager should deny access to invalid employee and dont log the attempt' do
    employee_id = '12345'
    direction = 'enter'
    lock_name = 'Main door'
    Role.create!(name: 'Normal user')
    main_door_lock = Lock.create!(name: lock_name)
    assert_equal(false, EmployeeAccessManager.new(employee_id, lock_name, direction).process)
    assert_equal(0, AccessLog.where({lock_id: main_door_lock.id, access_method: 'face_recognition'}).size)
  end

  test 'access manager should deny access to unknown lock and dont log the attempt' do
    employee_id = '12345'
    user = User.create!(name: 'test user', employee_id: employee_id, enabled: true)
    direction = 'enter'

    assert_equal(false, EmployeeAccessManager.new(employee_id, 'invalid lock', direction).process)
    assert_equal(0, AccessLog.where({access_method: 'face_recognition', user_id: user.id}).size)
  end

  test 'access manager should deny access to enabled employees who dont have permission for given door and log the attempt' do
    employee_id = 1234
    lock_name = 'Main door'
    direction = 'enter'
    user = User.create!(employee_id: employee_id, name: 'test user', enabled: true)
    lock = Lock.create!(name: lock_name)
    Role.create!(name: 'Normal user')

    assert_equal(false, EmployeeAccessManager.new(employee_id, lock_name, direction).process)
    assert_equal(1, AccessLog.where({user_id: user.id, lock_id: lock.id, access_method: 'face_recognition', direction: direction, access_provided: false}).size)
  end

end
