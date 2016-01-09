require 'test_helper'

class PodcastTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create :user
    @podcast = @user.podcasts.build(title: "New Games Podcast",
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

  # user

  test "podcast user should be present" do
    @podcast.user = nil
    assert_not @podcast.valid?
  end

  # published

  test "published should default to false" do
    assert_not @podcast.published
  end

  # end_time
end
