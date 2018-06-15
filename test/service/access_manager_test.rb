require './test/test_helper'

class AccessManagerTest < ActiveSupport::TestCase
  test 'access manager should give access to valid cards if the assigned user has permission for given lock and log the access' do
    card_number = 'AABBCCDD'
    lock_name = 'Main door'
    normal_user_role = Role.create!(name: 'Normal user')
    user = User.create!(name: 'test user', roles: [normal_user_role])
    Card.create!(card_number: card_number, user: user)
    main_door_lock = Lock.create!(name: lock_name)
    Permission.create!(role: normal_user_role, lock: main_door_lock)

    assert_equal(true, AccessManager.new(card_number, lock_name).process)
    assert_equal(1, AccessLog.where({user_id: user.id, card_number: card_number, lock_id: main_door_lock.id, direction: 'enter', access_provided: true}).size)
  end

  test 'access manager should deny access to invalid cards and log the attempt' do
    card_number = 'INVALID'
    actual = AccessManager.new(card_number, Lock.first.name).process
    assert_equal(false, actual)
    assert_equal(1, AccessLog.where({card_number: card_number, lock_id: Lock.first.id, direction: 'enter', access_provided: false}).size)
  end

  test 'access manager should deny access to unassigned cards and log the attempt' do
    card_number = 'AABBCCDD'
    Card.create!(card_number: card_number)
    assert_equal(false, AccessManager.new(card_number, Lock.first.name).process)
    assert_equal(1, AccessLog.where({card_number: card_number, lock_id: Lock.first.id, direction: 'enter', access_provided: false}).size)
  end

  test 'access manager should deny access to unknown lock and dont log the attempt' do
    card_number = 'AABBCCDD'
    user = User.create!(name: 'test user')
    invalid_lock_id = 110011001100
    Card.create!(card_number: card_number, user: user)
    assert_equal(false, AccessManager.new(card_number, 'invalid lock').process)
    assert_equal(0, AccessLog.where({card_number: card_number, lock_id: invalid_lock_id, direction: 'enter', access_provided: false}).size)
  end

  test 'access manager should deny access to valid cards if the assigned user dont have permission for given door and log the attempt' do
    card_number = 'AABBCCDD'
    lock_name = 'Main door'
    user = User.create!(name: 'test user')
    Card.create!(card_number: card_number, user: user)
    Lock.create!(name: lock_name)
    Role.create!(name: 'Normal user')
    assert_equal(false, AccessManager.new(card_number, Lock.first.name).process)
    assert_equal(1, AccessLog.where({card_number: card_number, lock_id: Lock.first.id, direction: 'enter', access_provided: false}).size)
  end

end
