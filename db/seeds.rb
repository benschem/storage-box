# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
#
#
puts "Destroying Items..."
Item.destroy_all
puts "Destroying Boxes..."
Box.destroy_all
puts "Destroying Rooms..."
Room.destroy_all
puts "Destroying Households..."
Household.destroy_all
puts "Destroying users..."
User.destroy_all

puts "Creating users..."
user = User.create!(
  email: 'benschembri@gmail.com',
  password: 'xfev-thyu-Ujmx-4Vop',
  password_confirmation: 'xfev-thyu-Ujmx-4Vop',
  name: 'Ben',
)
puts "User created: #{user.email}"

puts "Creating a Household..."
household = Household.create(address: "4/311 Dandenong Road Prahran")
user.households << household
puts "Household created: #{household.address}"

puts "Creating Room..."
room = Room.create(name: 'Garage', household: household)
puts "Room created: #{room.name}"
5.times do
  room = Room.create(name: Faker::House.room, household: household)
  puts "Room created: #{room.name}"
end

puts "Creating Boxes..."
15.times do
  box = Box.create(room: household.rooms.sample)
  puts "Box created: #{box.number}"
end

puts "Creating Items..."
100.times do
  item = Item.create(name: Faker::Appliance.equipment, box: household.boxes.sample)
  puts "Item created: #{item.name}"
end
