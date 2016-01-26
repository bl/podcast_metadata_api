require 'test_helper'

class PodcastTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create :user_with_series
    @series = @user.series.first
    @podcast = @series.podcasts.build(title: "New Games Podcast",
                                    podcast_file: fixture_file_upload('podcasts/edenlarge.mp3', 'audio/mpeg'))
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

  test "podcast_url should be valid and provide audio file" do
    @podcast.podcast_file = fixture_file_upload('images/rails.png', 'image/png')
    assert_not @podcast.valid?
    assert_match /is not a valid audio file/, @podcast.errors[:podcast_file].to_s
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


  # TODO: implement method of bypassing podcast metadata initialization before validation
  # end_time

#  test "end_time must be present" do
#    @podcast.end_time = nil
#    assert_not @podcast.valid?
#  end

#  test "end_time must be greater than or equal to 5 seconds" do
#    @podcast.end_time = 4
#    assert_not @podcast.valid?
#    @podcast.end_time = 5
#    assert @podcast.valid?
#  end

  # bitrate

#  test "bitrate must be present" do
#    @podcast.bitrate = nil
#    assert_not @podcast.valid?
#  end
end
