FactoryGirl.define do
  factory :podcast do
    transient do
      podcast_file_name "piano-loop.mp3"
    end

    title "Example Podcast"
    podcast_file { fixture_file_upload("test/fixtures/podcasts/#{podcast_file_name}", 'audio/mpeg') }
    series

    trait :published do
      published true
      published_at { Time.zone.now }
    end

    factory :published_podcast, traits: [:published]
  end

  factory :podcast_with_timestamps, parent: :published_podcast do
    transient do
      timestamps_count 3
    end

    after(:create) do |podcast, evaluator|
      create_list(:timestamp, evaluator.timestamps_count, podcast: podcast, podcast_end_time: podcast.end_time)
    end
  end
end
