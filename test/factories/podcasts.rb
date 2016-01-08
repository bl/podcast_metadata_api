FactoryGirl.define do
  factory :podcast do
    title "MyString"
    podcast_file { fixture_file_upload('test/fixtures/podcasts/edenlarge.mp3', 'audio/mpeg') }
    user
  end
end
