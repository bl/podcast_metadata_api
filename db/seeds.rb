# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# users (first user inactivated, rest activated)
10.times do |n|
  name = FFaker::Name.name
  email = "user-#{n}@example.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: (n == 0 ? false : true),
               activated_at: Time.zone.now )
end

# series
# associate series with first 3 users
3.times do |n|
  3.times do |j|
    User.where(activated: true)[n].series.create!(title: "Generic Series #{j}")
  end
end

# podcasts
# load podcasts from shared/seed_data/podcasts, associating each podcast with each user
cur_podcast = 0
seed_data_dir = File.expand_path('../../shared/seed_data/podcasts', __FILE__)
podcast_entries = Dir.entries seed_data_dir
podcast_entries.each do |podcast_file|
  next if '.' == podcast_file || '..' == podcast_file
  title =  "Generic Podcast #{cur_podcast}"

  puts "Creating Podcast: #{title} from file: #{podcast_file}"
  # add each podcast to next user (repeat once users exhausted)
  Series.all[cur_podcast % Series.count].podcasts.create!(title: title,
                                                   podcast_file: File.open( "#{seed_data_dir}/#{podcast_file}", "r"))

  cur_podcast += 1
end

# articles
# create articles for each user
User.where(activated: true).each do |user|
  3.times do
    user.articles.create!(content: FFaker::BaconIpsum.paragraphs)
  end
end
