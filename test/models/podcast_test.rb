require 'test_helper'

class PodcastTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create :user_with_series
    @series = @user.series.first
    @podcast = @series.podcasts.build(title: "New Games Podcast")
  end

  # verify podcast metadata properly initialized
  test "podcast should be valid" do
    assert @podcast.valid?
  end

  # title

  test "podcast title should be present" do
    @podcast.title = " "
    assert_not @podcast.valid?
  end

  test "podcast title should be less than 100 characters" do
    @podcast.title = "a" * 100
    assert @podcast.valid?

    @podcast.title += "a"
    assert_not @podcast.valid?
  end

  # podcast_file

  test "podcast_file should be valid and provide audio file" do
    @podcast.podcast_file = fixture_file_upload('podcasts/piano-loop.mp3', 'audio/mpeg')
    assert @podcast.valid?
    assert @podcast.end_time.present?
    assert @podcast.bitrate.present?

    @podcast.podcast_file = fixture_file_upload('images/rails.png', 'image/png')
    assert_not @podcast.valid?
    assert_match /is not a valid audio file/, @podcast.errors[:podcast_file].to_s
    assert_not @podcast.podcast_file.present?
    assert_nil @podcast.end_time
    assert_nil @podcast.bitrate
  end

  # clear_podcast_file

  test "podcast_file removal should clear end_time and bitrate" do
    @podcast.podcast_file = fixture_file_upload('podcasts/piano-loop.mp3', 'audio/mpeg')
    @podcast.clear_podcast_file

    assert @podcast.valid?
    assert_not @podcast.podcast_file.present?
    assert_nil @podcast.end_time
    assert_nil @podcast.bitrate
  end

  # series

  test "podcast series should be present" do
    @podcast.series = nil
    assert_not @podcast.valid?
  end

  # published

  test "published should default to false" do
    assert_not @podcast.published
  end

  test "publishable only when podcast_file is provided" do
    @podcast.attributes = { published: true, published_at: Time.zone.now }
    assert_not @podcast.valid?
    assert_match /Podcast cannot be published without an associated podcast file/, @podcast.errors[:base].to_s

    @podcast.podcast_file = fixture_file_upload('podcasts/piano-loop.mp3', 'audio/mpeg')
    assert @podcast.valid?
  end

  # store_podcast_file

  test "store_podcast_file sets podcast_file and saves record" do
    @podcast.podcast_file = nil
    @podcast.store_podcast_file(fixture_file_upload('podcasts/piano-loop.mp3', 'audio/mpeg'))
    assert @podcast.changes.empty?
    assert @podcast.podcast_file.present?
  end

  # end_time

  test "end_time must be present on valid podcast_file" do
    @podcast.podcast_file = fixture_file_upload('podcasts/piano-loop.mp3', 'audio/mpeg')
    @podcast.save
    @podcast.end_time = nil
    assert_not @podcast.valid?
  end

  test "end_time must be greater than or equal to 5 seconds" do
    @podcast.podcast_file = fixture_file_upload('podcasts/piano-loop.mp3', 'audio/mpeg')
    @podcast.save
    @podcast.end_time = 4
    assert_not @podcast.valid?

    @podcast.end_time = 5
    assert @podcast.valid?
  end

  # bitrate

  test "bitrate must be present on valid podcast_file" do
    @podcast.podcast_file = fixture_file_upload('podcasts/piano-loop.mp3', 'audio/mpeg')
    @podcast.save
    @podcast.bitrate = nil
    assert_not @podcast.valid?
  end

  test "bitrate must be greater than or equal to 5 seconds" do
    @podcast.podcast_file = fixture_file_upload('podcasts/piano-loop.mp3', 'audio/mpeg')
    @podcast.save
    @podcast.bitrate = -1
    assert_not @podcast.valid?

    @podcast.bitrate = 0
    assert @podcast.valid?
  end
end
