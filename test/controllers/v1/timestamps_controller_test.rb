require 'test_helper'

class V1::TimestampsControllerTest < ActionController::TestCase
  def setup
    2.times do
      FactoryGirl.create :podcast_with_timestamps
    end
    @podcast = FactoryGirl.create :podcast_with_timestamps
    @timestamps = @podcast.timestamps
    include_default_accept_headers
  end

  # SHOW

  test "should return valid json on timestamp get" do
    get :show, id: @timestamps.first
    timestamp_response = json_response[:data]
    assert_not_nil timestamp_response
    assert_equal @timestamps.first.id, timestamp_response[:id].to_i

    assert_response 200
  end

  test "should return json errors on invalid timetamp id get" do
    get :show, id: -1
    timestamp_errors = json_response[:errors]
    assert_not_nil timestamp_errors
    assert_match /Invalid timestamp/, timestamp_errors

    assert_response 403
  end

  # INDEX

  test "index should return valid json on all timestamps" do
    get :index
    timestamp_response = json_response[:data]
    assert_not_nil timestamp_response
    assert_equal Timestamp.count, timestamp_response.count

    assert_response 200
  end
end
