# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?

Lock.create!(name: 'Main entrance')
Lock.create!(name: 'Power room')
Lock.create!(name: 'Server room')

if Rails.env.development?
  Card.create!(card_number: 'FAFA01')
  Card.create!(card_number: 'FAFA02')
  Card.create!(card_number: 'FAFA03')
  Card.create!(card_number: 'FAFA04')
  Card.create!(card_number: 'FAFA05')
  Card.create!(card_number: 'FAFA06')
  Card.create!(card_number: 'FAFA07')
  Card.create!(card_number: 'FAFA08')
  Card.create!(card_number: 'FAFA09')
  Card.create!(card_number: 'FAFA10')

  Role.create!(name: 'Normal Employee')
  Role.create!(name: 'Infra team')
  Role.create!(name: 'Electrician')
  Role.create!(name: 'Security')

  User.create!(name: 'Test user 1')
  User.create!(name: 'Test user 2')
  User.create!(name: 'Test user 3')
end
