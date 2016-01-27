require 'test_helper'

class SeriesTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create :user_with_series
    @series = @user.series.build(title: "Generic Music Podcast")
  end

  test "series is valid" do
    assert @series.valid?
  end

  test "title should be present" do
    @series.title = " "
    assert_not @series.valid?
  end

  test "user should be present" do
    @series.user = nil
    assert_not @series.valid?
  end

  test "title should be less than or equal to 100 characters" do
    @series.title = "a" * 100
    assert @series.valid?
    @series.title += "a"
    assert_not @series.valid?
  end

  test "description should be less than or equal to 1000 characters" do
    @series.description = "a" * 1000
    assert @series.valid?
    @series.description += "a"
    assert_not @series.valid?
  end

  test "series should not be published by default" do
    assert_not @series.published
  end
end
