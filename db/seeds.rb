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
puts "Destroying Houses..."
House.destroy_all
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

puts "Creating a House..."
house = House.create(address: "4/311 Dandenong Road Prahran")
user.houses << house
puts "House created: #{house.address}"

puts "Creating Room..."
room = Room.create(name: 'Garage', house: house)
puts "Room created: #{room.name}"
5.times do
  room = Room.create(name: Faker::House.room, house: house)
  puts "Room created: #{room.name}"
end

puts "Creating Tags..."
10.times do
  tag = Tag.create(house: house, name: Faker::Hobby.activity.downcase)
  puts "Tag created: #{tag.name}"
end

puts "Creating Boxes..."
15.times do
  box = Box.create(room: house.rooms.sample)
  (0..4).to_a.sample.times do
    random_tag = Tag.where(house: house).sample
    unless box.tags.include?(random_tag)
      box.tags << random_tag
      puts "Tag added: #{random_tag.name}"
    end
  end
  puts "Box created: #{box.number}"
end



puts "Creating Items..."
100.times do
  item = Item.create(name: Faker::Appliance.equipment, box: house.boxes.sample)
  puts "Item created: #{item.name}"
end
