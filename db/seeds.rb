# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# create Users

User.create!(name: "Example User",
             email: "example@rails.org",
             password: "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true)

99.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@rails.org"
  User.create!(name: name,
               email: email,
               password: "password",
               password_confirmation: "password",
               activated: true)
end

# create some Microposts
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
end

# have some users follow each other
users = User.all
user = users.first
following = users[2..50]
followers = users[3..40]
following.each { |a| user.follow(a) }
followers.each { |a| a.follow(user) }
