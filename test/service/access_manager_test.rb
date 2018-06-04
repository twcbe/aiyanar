require './test/test_helper'

class AccessManagerTest < ActiveSupport::TestCase
  test 'access manager should give access to valid cards if the assigned user has permission for given lock' do
    card_number = 'AABBCCDD'
    lock_name = 'Main door'
    normal_user_role = Role.create!(name: 'Normal user')
    user = User.create!(name: 'test user', roles: [normal_user_role])
    Card.create!(card_number: card_number, user: user)
    main_door_lock = Lock.create!(name: lock_name)
    Permission.create!(role: normal_user_role, lock: main_door_lock)

    assert_equal(true, AccessManager.authorize(card_number, lock_name))
  end

  test 'access manager should deny access to invalid cards' do
    card_number = 'INVALID'
    actual = AccessManager.authorize(card_number, Lock.first.name)
    assert_equal(false, actual)
  end

  test 'access manager should deny access to unassigned cards' do
    card_number = 'AABBCCDD'
    Card.create!(card_number: card_number)
    assert_equal(false, AccessManager.authorize(card_number, Lock.first.name))
  end

  test 'access manager should deny access to unknown lock' do
    card_number = 'AABBCCDD'
    user = User.create!(name: 'test user')
    Card.create!(card_number: card_number, user: user)
    assert_equal(false, AccessManager.authorize(card_number, 'invalid lock'))
  end

  test 'access manager should deny access to valid cards if the assigned user dont have permission for given door' do
    card_number = 'AABBCCDD'
    lock_name = 'Main door'
    user = User.create!(name: 'test user')
    Card.create!(card_number: card_number, user: user)
    Lock.create!(name: lock_name)
    Role.create!(name: 'Normal user')
    assert_equal(false, AccessManager.authorize(card_number, Lock.first.name))
  end

end
