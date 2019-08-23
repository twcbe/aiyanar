require './test/test_helper'

class CardAccessManagerTest < ActiveSupport::TestCase
  test 'access manager should give access to valid cards if the assigned user and card is enabled and has permission for given lock and log the access' do
    card_number = 'AABBCCDD'
    lock_name = 'Main door'
    direction = 'enter'
    normal_user_role = Role.create!(name: 'Normal user')
    user = User.create!(name: 'test user', roles: [normal_user_role], enabled: true)
    Card.create!(card_number: card_number, user: user, enabled: true)
    main_door_lock = Lock.create!(name: lock_name)
    Permission.create!(role: normal_user_role, lock: main_door_lock)

    assert_equal(true, CardAccessManager.new(card_number, lock_name, direction).process)
    assert_equal(1, AccessLog.where({user_id: user.id, access_method: 'access_card', card_number: card_number, lock_id: main_door_lock.id, direction: direction, access_provided: true}).size)
  end

  test 'access manager should deny access to invalid cards and log the attempt' do
    card_number = 'INVALID'
    direction = 'enter'
    lock_name = 'Main door'
    Lock.create!(name: lock_name)
    actual = CardAccessManager.new(card_number, Lock.first.name, direction).process
    assert_equal(false, actual)
    assert_equal(1, AccessLog.where({access_method: 'access_card', card_number: card_number, lock_id: Lock.first.id, direction: direction, access_provided: false}).size)
  end

  test 'access manager should deny access to unassigned cards and log the attempt' do
    card_number = 'AABBCCDD'
    direction = 'enter'
    Card.create!(card_number: card_number, enabled: true)
    lock_name = 'Main door'
    Lock.create!(name: lock_name)
    assert_equal(false, CardAccessManager.new(card_number, Lock.first.name, direction).process)
    assert_equal(1, AccessLog.where({access_method: 'access_card', card_number: card_number, lock_id: Lock.first.id, direction: direction, access_provided: false}).size)
  end

  test 'access manager should deny access to unknown lock and dont log the attempt' do
    card_number = 'AABBCCDD'
    user = User.create!(name: 'test user', enabled: true)
    direction = 'enter'
    Card.create!(card_number: card_number, user: user, enabled: true)

    assert_equal(false, CardAccessManager.new(card_number, 'invalid lock', direction).process)
    assert_equal(0, AccessLog.where({access_method: 'access_card', card_number: card_number, direction: direction, access_provided: false}).size)
  end

  test 'access manager should deny access to valid cards if the assigned user is enabled but dont have permission for given door and log the attempt' do
    card_number = 'AABBCCDD'
    lock_name = 'Main door'
    direction = 'enter'
    user = User.create!(name: 'test user', enabled: true)
    Card.create!(card_number: card_number, user: user, enabled: true)
    Lock.create!(name: lock_name)
    Role.create!(name: 'Normal user')

    assert_equal(false, CardAccessManager.new(card_number, Lock.first.name, direction).process)
    assert_equal(1, AccessLog.where({access_method: 'access_card', card_number: card_number, lock_id: Lock.first.id, direction: direction, access_provided: false}).size)
  end

  test 'access manager should deny access to valid cards if the assigned user have permission for given door but is disabled and log the attempt' do
    card_number = 'AABBCCDD'
    lock_name = 'Main door'
    direction = 'enter'
    user = User.create!(name: 'test user', enabled: false)
    Card.create!(card_number: card_number, user: user, enabled: true)
    main_door_lock = Lock.create!(name: lock_name)
    normal_user_role = Role.create!(name: 'Normal user')
    Permission.create!(role: normal_user_role, lock: main_door_lock)

    assert_equal(false, CardAccessManager.new(card_number, main_door_lock.name, direction).process)
    assert_equal(1, AccessLog.where({access_method: 'access_card', card_number: card_number, lock_id: main_door_lock.id, direction: direction, access_provided: false}).size)
  end

  test 'access manager should deny access to valid cards if the assigned user is enabled and have permission for given door but card is disabled and log the attempt' do
    card_number = 'AABBCCDD'
    lock_name = 'Main door'
    direction = 'enter'
    normal_user_role = Role.create!(name: 'Normal user')
    user = User.create!(name: 'test user', roles: [normal_user_role], enabled: true)
    Card.create!(card_number: card_number, user: user, enabled: false)
    main_door_lock = Lock.create!(name: lock_name)
    Permission.create!(role: normal_user_role, lock: main_door_lock)

    assert_equal(false, CardAccessManager.new(card_number, main_door_lock.name, direction).process)
    assert_equal(1, AccessLog.where({access_method: 'access_card', card_number: card_number, lock_id: main_door_lock.id, direction: direction, access_provided: false}).size)
  end

end
