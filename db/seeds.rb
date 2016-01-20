# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# users
10.times do |n|
  name = FFaker::Name.name
  email = "user-#{n}@example.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password:              password,
               password_confirmation: password)
end

# podcasts
cur_podcast = 0
seed_data_dir = File.expand_path('../../shared/seed_data', __FILE__)
podcast_entries = Dir.entries seed_data_dir
users = User.all
podcast_entries.each do |podcast_file|
  next if '.' == podcast_file || '..' == podcast_file
  title =  "Generic Podcast #{cur_podcast}"

  puts "Creating Podcast: #{title} from file: #{podcast_file}"
  # add each podcast to next user (repeat once users exhausted)
  users[cur_podcast % User.count].podcasts.create!(title: title,
                                                   podcast_file: File.open( "#{seed_data_dir}/#{podcast_file}", "r"))

  cur_podcast += 1
end
