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
puts "Destroying tags..."
Tag.destroy_all
puts "Destroying users..."
User.destroy_all

puts "Creating users..."
user = User.create!(
  email: 'benschembri@gmail.com',
  password: 'password',
  password_confirmation: 'password',
  name: 'Ben',
)
puts "User created: #{user.email}"

puts "Creating a House..."
house = House.create(name: "Home")
user.houses << house
puts "House created: #{house.name}"

puts "Creating a second House..."
house2 = House.create(name: "Mum and dad's place")
user.houses << house2
puts "House created: #{house2.name}"

puts "Creating Room..."
room = Room.create(name: 'Garage', house: house)
puts "Room created: #{room.name}"
5.times do
  room = Room.create(name: Faker::House.room, house: house)
  puts "Room created: #{room.name}"
end

puts "Creating Tags..."
10.times do
  tag = Tag.create(user: user, name: Faker::Hobby.activity.downcase)
  puts "Tag created: #{tag.name}"
end

puts "Creating Boxes..."
15.times do
  box = Box.create(room: house.rooms.sample)
  puts "Box created: #{box.number}"
end

puts "Creating Items..."
100.times do
  has_notes = [true, true, false].sample
  if has_notes
    item = Item.create(
      name: Faker::Appliance.equipment,
      notes: Faker::TvShows::HowIMetYourMother.quote,
      box: house.boxes.sample
    )
  else
    item = Item.create(
      name: Faker::Appliance.equipment,
      box: house.boxes.sample
    )
  end
  puts "Item created: #{item.name}"

  (0..4).to_a.sample.times do
    random_tag = Tag.where(user: user).sample
    unless item.tags.include?(random_tag)
      item.tags << random_tag
      puts "Tag added: #{random_tag.name}"
    end
  end
end
