require 'test_helper'

class Api::V1::TimestampsControllerTest < ActionController::TestCase
  include ResourcesControllerTest

  def setup
    # create additional data
    2.times do
      FactoryGirl.create :podcast_with_timestamps
    end
    @podcast = FactoryGirl.create :podcast
    @podcast_with_timestamps = FactoryGirl.create :podcast_with_timestamps
    @timestamps = @podcast_with_timestamps.timestamps
    include_default_accept_headers
  end

  def resource_class
    Timestamp
  end

  def user
    @podcast.series.user
  end

  def user_with_resources
    @podcast_with_timestamps.series.user
  end

  def resources_for user
    user.series.first.podcasts.first.timestamps
  end

  def valid_resource_attributes
    { start_time: 10, end_time: nil }
  end

  def invalid_resource_attributes
    { start_time: 10, end_time: 5 }
  end

  def invalid_attribute_id
    'end_time'
  end

  def invalid_attribute_detail
    'must be less than start time'
  end

  def post_params
    { podcast_id: @podcast }
  end

  # SHOW

  test "should return valid json on timestamp get" do
    get :show, params: { id: @timestamps.first }
    timestamp_response = json_response[:data]
    assert_not_nil timestamp_response
    assert_equal @timestamps.first.id, timestamp_response[:id].to_i

    assert_response 200
  end

  # INDEX

  test "index should return empty timestamps list with invalid podcast_id param" do
    get :index, params: { podcast_id: -1 }
    timestamp_response = json_response[:data]
    assert_not_nil timestamp_response
    assert_equal 0, timestamp_response.count

    assert_response 200
  end

  test "index should return podcast timestamps with podcast_id param" do
    get :index, params: { podcast_id: @podcast_with_timestamps.id }
    timestamp_response = json_response[:data]
    assert_not_nil timestamp_response
    assert_equal @timestamps.count, timestamp_response.count
    timestamp_response.each do |res|
      assert @podcast_with_timestamps.timestamp_ids.include? res[:id].to_i
    end

    assert_response 200
  end

  # CREATE

  test "create should return json errors on non-logged in users podcast" do
    valid_timestamp_attributes = { start_time: 5, end_time: 10 }
    assert_no_difference '@podcast.timestamps.count' do
      post_as @podcast_with_timestamps.series.user, :create, params: { podcast_id: @podcast, timestamp: valid_timestamp_attributes }
    end
    validate_response json_response[:errors], /podcast/, /is invalid/

    assert_response 422
  end
end
