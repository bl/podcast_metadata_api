require 'test_helper'

class PodcastTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create :user
    @podcast = @user.podcasts.build(title: "New Games Podcast",
                                    podcast_url: "http://www.magnac.com/sounds/edenlarge.mp3")
  end

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

  # podcast_url

  test "podcast_url should be present" do
    @podcast.podcast_url = " "
    assert_not @podcast.valid?
  end

  #TODO: podcast_url should be valid and provide audio file

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

  #TODO: end_time should be generated on create
end
