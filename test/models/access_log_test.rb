require 'test_helper'

class AccessLogTest < ActiveSupport::TestCase
  test "AccessLog.recent_logs_for_user should return the access logs for the given user" do
    user1 = User.create! name: 'test user 1'
    user2 = User.create! name: 'test user 2'
    user3 = User.create! name: 'test user 3'
    lock1 = Lock.create! name: 'Main entrance'
    lock2 = Lock.create! name: 'some door 1'
    lock3 = Lock.create! name: 'some door 2'

    AccessLog.create! lock_id: lock1.id, card_number: 'A1', user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: 'A1', user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: 'A1', user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: 'A1', user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock3.id, card_number: 'A1', user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: false

    AccessLog.create! lock_id: lock1.id, card_number: 'B1', user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: false
    AccessLog.create! lock_id: lock2.id, card_number: 'B1', user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: false

    AccessLog.create! lock_id: lock1.id, card_number: 'C1', user_id: user3.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: 'C1', user_id: user3.id, direction: AccessLog.directions[:exit], access_provided: true

    access_logs_for_user1 = AccessLog.recent_logs_for_user(user1, 10)
    access_logs_for_user2 = AccessLog.recent_logs_for_user(user2, 10)
    access_logs_for_user3 = AccessLog.recent_logs_for_user(user3, 10)

    assert_equal 5, access_logs_for_user1.size
    assert_equal 2, access_logs_for_user2.size
    assert_equal 2, access_logs_for_user3.size

    assert_equal(true, access_logs_for_user1.all? {|log| log.user_id == user1.id})
    assert_equal(true, access_logs_for_user2.all? {|log| log.user_id == user2.id})
    assert_equal(true, access_logs_for_user3.all? {|log| log.user_id == user3.id})
  end

  test "AccessLog.recent_logs_for_user should return only most recent N access logs for the given user" do
    user1 = User.create! name: 'test user 1'
    user2 = User.create! name: 'test user 2'
    user3 = User.create! name: 'test user 3'
    lock1 = Lock.create! name: 'Main entrance'
    lock2 = Lock.create! name: 'some door 1'

    AccessLog.create! lock_id: lock1.id, card_number: 'A1', user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: 'A1', user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: 'A1', user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: 'A1', user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: 'A1', user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: false

    AccessLog.create! lock_id: lock1.id, card_number: 'B1', user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: false
    AccessLog.create! lock_id: lock2.id, card_number: 'B1', user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: false

    AccessLog.create! lock_id: lock1.id, card_number: 'C1', user_id: user3.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: 'C1', user_id: user3.id, direction: AccessLog.directions[:exit], access_provided: true

    access_logs_for_user1 = AccessLog.recent_logs_for_user(user1, 3)

    assert_equal 3, access_logs_for_user1.size
    assert_equal(true, access_logs_for_user1.all? {|log| log.user_id == user1.id}, 'wrong user')
    assert_equal(true, access_logs_for_user1.all? {|log| log.lock_id == lock2.id}, 'wrong order')
  end

  test "AccessLog.recent_logs_for_card_number should return the access logs for the given card_number" do
    user1 = User.create! name: 'test user 1'
    user2 = User.create! name: 'test user 2'
    user3 = User.create! name: 'test user 3'
    lock1 = Lock.create! name: 'Main entrance'
    lock2 = Lock.create! name: 'some door 1'
    lock3 = Lock.create! name: 'some door 2'

    card_number1 = 'A1'
    card_number2 = 'B1'
    card_number3 = 'C1'

    AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock3.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: false

    AccessLog.create! lock_id: lock1.id, card_number: card_number2, user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: false
    AccessLog.create! lock_id: lock2.id, card_number: card_number2, user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: false

    AccessLog.create! lock_id: lock1.id, card_number: card_number3, user_id: user3.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: card_number3, user_id: user3.id, direction: AccessLog.directions[:exit], access_provided: true

    access_logs_for_card1 = AccessLog.recent_logs_for_card_number(card_number1, 100)
    access_logs_for_card2 = AccessLog.recent_logs_for_card_number(card_number2, 100)
    access_logs_for_card3 = AccessLog.recent_logs_for_card_number(card_number3, 100)

    assert_equal 5, access_logs_for_card1.size
    assert_equal 2, access_logs_for_card2.size
    assert_equal 2, access_logs_for_card3.size

    assert_equal(true, access_logs_for_card1.all? {|log| log.card_number == card_number1})
    assert_equal(true, access_logs_for_card2.all? {|log| log.card_number == card_number2})
    assert_equal(true, access_logs_for_card3.all? {|log| log.card_number == card_number3})
  end

  test "AccessLog.recent_logs_for_card_number should return only most recent N access logs for the given card number" do
    user1 = User.create! name: 'test user 1'
    user2 = User.create! name: 'test user 2'
    user3 = User.create! name: 'test user 3'
    lock1 = Lock.create! name: 'Main entrance'
    lock2 = Lock.create! name: 'some door 1'

    card_number1 = 'A1'
    card_number2 = 'B1'
    card_number3 = 'C1'

    AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: false

    AccessLog.create! lock_id: lock1.id, card_number: card_number2, user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: false
    AccessLog.create! lock_id: lock2.id, card_number: card_number2, user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: false

    AccessLog.create! lock_id: lock1.id, card_number: card_number3, user_id: user3.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: card_number3, user_id: user3.id, direction: AccessLog.directions[:exit], access_provided: true

    access_logs_for_card1 = AccessLog.recent_logs_for_card_number(card_number1, 3)

    assert_equal 3, access_logs_for_card1.size
    assert_equal(true, access_logs_for_card1.all? {|log| log.card_number == card_number1}, 'wrong card')
    assert_equal(true, access_logs_for_card1.all? {|log| log.lock_id == lock2.id}, 'wrong order')
  end

  test "AccessLog.recent_logs_for_lock should return the access logs for the given lock" do
    user1 = User.create! name: 'test user 1'
    user2 = User.create! name: 'test user 2'
    user3 = User.create! name: 'test user 3'
    lock1 = Lock.create! name: 'Main entrance'
    lock2 = Lock.create! name: 'some door 1'
    lock3 = Lock.create! name: 'some door 2'

    card_number1 = 'A1'
    card_number2 = 'B1'
    card_number3 = 'C1'

    AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: card_number2, user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: false
    AccessLog.create! lock_id: lock1.id, card_number: card_number3, user_id: user3.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: card_number3, user_id: user3.id, direction: AccessLog.directions[:exit], access_provided: true

    AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: card_number2, user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: false

    AccessLog.create! lock_id: lock3.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: false


    access_logs_for_lock1 = AccessLog.recent_logs_for_lock(lock1, 100)
    access_logs_for_lock2 = AccessLog.recent_logs_for_lock(lock2, 100)
    access_logs_for_lock3 = AccessLog.recent_logs_for_lock(lock3, 100)

    assert_equal 5, access_logs_for_lock1.size
    assert_equal 3, access_logs_for_lock2.size
    assert_equal 1, access_logs_for_lock3.size

    assert_equal(true, access_logs_for_lock1.all? {|log| log.lock_id == lock1.id})
    assert_equal(true, access_logs_for_lock2.all? {|log| log.lock_id == lock2.id})
    assert_equal(true, access_logs_for_lock3.all? {|log| log.lock_id == lock3.id})
  end

  test "AccessLog.recent_logs_for_lock should return only most recent N access logs for the given lock" do
    user1 = User.create! name: 'test user 1'
    user2 = User.create! name: 'test user 2'
    user3 = User.create! name: 'test user 3'
    lock1 = Lock.create! name: 'Main entrance'
    lock2 = Lock.create! name: 'some door 1'

    card_number1 = 'A1'
    card_number2 = 'B1'
    card_number3 = 'C1'

    AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: card_number3, user_id: user3.id, direction: AccessLog.directions[:enter], access_provided: true
    AccessLog.create! lock_id: lock1.id, card_number: card_number3, user_id: user3.id, direction: AccessLog.directions[:enter], access_provided: false
    AccessLog.create! lock_id: lock1.id, card_number: card_number3, user_id: user3.id, direction: AccessLog.directions[:exit], access_provided: true

    AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true
    AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: false
    AccessLog.create! lock_id: lock2.id, card_number: card_number2, user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: false

    access_logs_for_lock1 = AccessLog.recent_logs_for_lock(lock1, 3)

    assert_equal 3, access_logs_for_lock1.size
    # assert_equal(true, access_logs_for_card1.all? {|log| log.card_number == card_number1}, 'wrong card')
    # assert_equal(true, access_logs_for_card1.all? {|log| log.lock_id == lock2.id}, 'wrong order')
  end
end
