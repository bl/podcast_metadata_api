require 'test_helper'

class TimestampTest < ActiveSupport::TestCase
  def setup
    # create podcast using file 'edenlarge.mp3', running time of 32 seconds
    @podcast = FactoryGirl.create :podcast, podcast_file_name: 'edenlarge.mp3'
    @timestamp = @podcast.timestamps.build( start_time: 5, end_time: 20)
  end

  test "timestamp should be valid" do
    assert @timestamp.valid?
  end

  # start_time

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

  # end_time

  test "end_time should be gerater than start_time" do
    @timestamp.start_time = 10 
    @timestamp.end_time = 5 
    assert_not @timestamp.valid?
    assert_match /must be less than start time/, @timestamp.errors[:end_time].to_s
    @timestamp.start_time = 10 
    @timestamp.end_time = 10 
    assert_not @timestamp.valid?
    assert_match /must be less than start time/, @timestamp.errors[:end_time].to_s
    @timestamp.end_time = 11
    assert @timestamp.valid?
  end

  test "start_time and end_time must be less than podcast end_time" do
    podcast = @timestamp.podcast
    @timestamp.start_time = podcast.end_time+1
    @timestamp.end_time   = podcast.end_time+1
    assert_not @timestamp.valid?
    assert_match /must be within podcast length/, @timestamp.errors[:start_time].to_s
    assert_match /must be within podcast length/, @timestamp.errors[:end_time].to_s
    @timestamp.start_time = podcast.end_time
    @timestamp.end_time   = podcast.end_time
    assert_not @timestamp.valid?
    assert_match /must be within podcast length/, @timestamp.errors[:start_time].to_s
    assert_match /must be within podcast length/, @timestamp.errors[:end_time].to_s
    @timestamp.start_time = podcast.end_time-2
    @timestamp.end_time   = podcast.end_time-1
    assert @timestamp.valid?
  end

  # podcast

  test "timestamps podcast should be present" do
    @timestamp.podcast = nil
    assert_not @timestamp.valid?
    assert_match /can't be blank/, @timestamp.errors[:podcast_id].to_s
  end
end
