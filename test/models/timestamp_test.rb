require 'test_helper'

class TimestampTest < ActiveSupport::TestCase
  def setup
    @podcast = FactoryGirl.create :podcast
    @timestamp = @podcast.timestamps.build( start_time: 30, end_time: 120)
  end

  test "timestamp should be valid" do
    assert @timestamp.valid?
  end

  test "start_time should be present" do
    @timestamp.start_time = nil
    assert_not @timestamp.valid?
  end

  test "start_time should be greater than or equal to 0" do
    @timestamp.start_time = -1
    assert_not @timestamp.valid?
    @timestamp.start_time = 0
    assert @timestamp.valid?
  end

  test "end_time should be gerater than start_time" do
    @timestamp.start_time = 10 
    @timestamp.end_time = 5 
    assert_not @timestamp.valid?
    @timestamp.start_time = 10 
    @timestamp.end_time = 10 
    assert_not @timestamp.valid?
    @timestamp.end_time = 11
    assert @timestamp.valid?
  end

  test "timestamps podcast should be present" do
    @timestamp.podcast = nil
    assert_not @timestamp.valid?
  end
end
