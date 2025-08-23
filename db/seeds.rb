# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
#
#
ActiveRecord::Base.transaction do
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
  password = 'strongPassword~123'

  user = User.create!(
    email: 'benschembri@gmail.com',
    password: password,
    password_confirmation: password,
    name: 'Ben',
  )
  puts "User created: #{user.name}"
  puts "username: #{user.email}"
  puts "password: #{password}"

  second_user = User.create!(
    email: 'sarrahmorrmorr@gmail.com',
    password: password,
    password_confirmation: password,
    name: 'Morrie',
  )
  puts "User created: #{second_user.name}"
  puts "username: #{second_user.email}"
  puts "password: #{password}"

  puts "Creating a House..."
  house = House.create!(name: "Home")
  user.houses << house
  puts "House created: #{house.name}"

  puts "Creating a second House..."
  house2 = House.create!(name: "Mum and dad's place")
  user.houses << house2
  puts "House created: #{house2.name}"

  puts "Creating Rooms..."
  room = Room.create!(name: 'Garage', house: house)
  puts "Room created: #{room.name}"
  5.times do
    room = Room.create!(name: Faker::House.room.capitalize, house: house)
    puts "Room created: #{room.name}"
  end

  puts "Creating Boxes..."
  15.times do
    room = house.rooms.sample
    box = Box.create!(room: room, house: room.house)
    puts "Box created: #{box.number}"
  end

  puts "Creating Tags..."
  until Tag.count == 10 do
    tag = Tag.create!(name: Faker::Hobby.activity.downcase) rescue ActiveRecord::RecordInvalid
    puts "Tag created: #{tag.name}"
  end

  puts "Creating Items..."
  tags = Tag.all
  100.times do
    has_notes = [true, true, false].sample
    box = house.boxes.sample
    item = Item.create!(
      name: Faker::Appliance.equipment,
      notes: has_notes ? Faker::TvShows::HowIMetYourMother.quote[0, 255] : nil,
      box: box,
      house: house,
      room: box.room,
      user: user
    )
    puts "Item created: #{item.name}"

    (0..4).to_a.sample.times do
      random_tagging = Tagging.find_or_create_by!(item: item, tag: tags.sample)
      puts "Tag '#{random_tagging.tag.name}' added to item '#{item.name}'"
    end
  end
end
