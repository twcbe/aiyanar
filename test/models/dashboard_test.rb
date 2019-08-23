require 'test_helper'

class DashboardTest < ActiveSupport::TestCase
    test "People_Behind_a_Room_Entered_By_Different_Locks" do
        user1=User.create! name:'test user1'
        user2=User.create! name:'test user2'

        card_number1='1A'
        card_number2='2A'

        room1 = Room.create! name:'Main space'

        lock1 = Lock.create! name: 'Main entrance', room_id:room1.id
        lock2 = Lock.create! name: 'Side entrance', room_id:room1.id

        AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
        AccessLog.create! lock_id: lock2.id, card_number: card_number2, user_id: user2.id, direction: AccessLog.directions[:enter], access_provided: true

        access_logs_for_lock1 = AccessLog.latest_for_users_currently_behind_lock(lock1)
        access_logs_for_lock2 = AccessLog.latest_for_users_currently_behind_lock(lock2)

        access_logs_for_room1 = AccessLog.latest_for_users_currently_behind_room(room1)

        assert_equal access_logs_for_room1.size, (access_logs_for_lock1.size+access_logs_for_lock2.size)
    end

    test "latest_for_users_currently_behind_room should show the user inside the office if they entered through main entrance and did not leave the office" do
        user1 = User.create! name:'test user1'

        card_number1 = '1A'

        room1 = Room.create! name:'Office'

        lock1 = Lock.create! name: 'Main entrance', room_id:room1.id

        AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true

        access_logs_for_room1 = AccessLog.latest_for_users_currently_behind_room(room1)

        assert_equal 1, access_logs_for_room1.size

        assert_equal user1.id, access_logs_for_room1.first.user.id
    end

    test "latest_for_users_currently_behind_room should not show the user as inside the office if they entered though main entrance and left the office through side entrance" do
        user1 = User.create! name:'test user1'

        card_number1 = '1A'

        room1 = Room.create! name:'Office'

        lock1 = Lock.create! name: 'Main entrance', room_id:room1.id
        lock2 = Lock.create! name: 'Side entrance', room_id:room1.id

        AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
        AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true

        access_logs_for_room1 = AccessLog.latest_for_users_currently_behind_room(room1)

        assert_equal 0, access_logs_for_room1.size
    end

    test "latest_for_users_currently_behind_room should show the user as inside main space if they entered main space, entered server room and exited server room" do
        user1 = User.create! name:'test user1'

        card_number1 = '1A'

        room1 = Room.create! name:'Main space'
        room2 = Room.create! name:'Server room'

        lock1 = Lock.create! name: 'Main entrance', room_id:room1.id
        lock2 = Lock.create! name: 'Server entrance', room_id:room2.id

        AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
        AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: true
        AccessLog.create! lock_id: lock2.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:exit], access_provided: true

        access_logs_for_room1 = AccessLog.latest_for_users_currently_behind_room(room1)

        assert_equal 1, access_logs_for_room1.size
        assert_equal user1.id, access_logs_for_room1.first.user.id
    end

    test "latest_for_users_currently_behind_room should not show the user as inside main space if the access was denied at main entrance" do

        user1 = User.create! name:'test user1'

        card_number1 = '1A'

        room1 = Room.create! name:'Main space'

        lock1 = Lock.create! name: 'Main entrance', room_id:room1.id

         AccessLog.create! lock_id: lock1.id, card_number: card_number1, user_id: user1.id, direction: AccessLog.directions[:enter], access_provided: false

        access_logs_for_room1 = AccessLog.latest_for_users_currently_behind_room(room1)

        assert_equal 0, access_logs_for_room1.size
    end
end












