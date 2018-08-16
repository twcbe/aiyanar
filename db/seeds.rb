# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

main_entrance = Lock.create!(name: 'Main entrance')
power_room = Lock.create!(name: 'Power room')
server_room = Lock.create!(name: 'Server room')

if Rails.env.development?
  card1 = Card.create!(card_number: 'FAFA01')
  card2 = Card.create!(card_number: 'FAFA02')
  Card.create!(card_number: 'FAFA03')
  Card.create!(card_number: 'FAFA04')
  Card.create!(card_number: 'FAFA05')
  Card.create!(card_number: 'FAFA06')
  Card.create!(card_number: 'FAFA07')
  Card.create!(card_number: 'FAFA08')
  Card.create!(card_number: 'FAFA09')
  card0 = Card.create!(card_number: 'FAFA10')

  Role.create!(name: 'Normal Employee')
  Role.create!(name: 'Infra team')
  Role.create!(name: 'Electrician')
  Role.create!(name: 'Security')

  user1 = User.create!(name: 'Test user 1')
  user2 = User.create!(name: 'Test user 2')
  user3 = User.create!(name: 'Test user 3')

  AccessLog.create!(lock_id: power_room.id, card_number: card0.card_number, access_method: 'access_card', access_provided: false, direction: 'enter')
  AccessLog.create!(user_id: user1.id, lock_id: power_room.id, card_number: card1.card_number, access_method: 'access_card', access_provided: true, direction: 'enter')
  AccessLog.create!(user_id: user1.id, lock_id: main_entrance.id, card_number: card1.card_number, access_method: 'access_card', access_provided: true, direction: 'exit')
  AccessLog.create!(user_id: user1.id, lock_id: server_room.id, card_number: card1.card_number, access_method: 'access_card', access_provided: false, direction: 'enter')
  AccessLog.create!(user_id: user2.id, lock_id: power_room.id, card_number: card2.card_number, access_method: 'access_card', access_provided: true, direction: 'enter')
  AccessLog.create!(user_id: user2.id, lock_id: power_room.id, card_number: card2.card_number, access_method: 'access_card', access_provided: true, direction: 'exit')
  AccessLog.create!(user_id: user2.id, lock_id: main_entrance.id, access_method: 'face_recognition', access_provided: true, direction: 'enter')
  AccessLog.create!(user_id: user2.id, lock_id: main_entrance.id, access_method: 'face_recognition', access_provided: true, direction: 'exit')
  AccessLog.create!(user_id: user3.id, lock_id: main_entrance.id, access_method: 'face_recognition', access_provided: false, direction: 'enter')
end
