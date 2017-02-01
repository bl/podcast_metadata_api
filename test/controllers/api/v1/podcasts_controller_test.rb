require 'test_helper'

class Api::V1::PodcastsControllerTest < ActionController::TestCase
  include ResourcesControllerTest
  include PublishedControllerTest
  include PaginatedControllerTest
  include LimitedSearchControllerTest

  def setup
    # create additional data
    2.times do
      FactoryGirl.create :user_with_published_podcasts
    end
    # user with empty series
    @user = (FactoryGirl.create :user_with_series, series_count: 1)
    @series = @user.series.first

    # user with series containing published podcasts (3 in first series, 1 in second series)
    @user_with_podcasts = FactoryGirl.create :user_with_published_podcasts
    @podcasts = @user_with_podcasts.series.first.podcasts

    # user with series containing unpublished podcasts (3 in first series, 1 in second series)
    @user_with_unpublished_podcasts = FactoryGirl.create(:user_with_unpublished_podcasts, series_count: 3)
    include_default_accept_headers
  end

  # interface methods for included resource tests

  def resource_class
    Podcast
  end

  def user
    @user
  end

  def user_with_resources
    @user_with_podcasts
  end

  def user_with_unpublished_resources
    @user_with_unpublished_podcasts
  end

  def all_published_resources
    Podcast.where published: true
  end

  def resources_for user
    user.series.first.podcasts
  end

  def published_resources_for user
    user.series.first.published_podcasts
  end

  def valid_resource_attributes
    valid_podcast_attributes = {
      title: "New Podcast Name",
      podcast_file: open_podcast_file('piano-loop.mp3')
    }
  end

  def invalid_resource_attributes
    invalid_podcast_attributes = {
      title: " "
    }
  end

  def invalid_attribute_id
    'title'
  end

  def invalid_attribute_detail
    "can't be blank"
  end

  def post_params
    { series_id: @series }
  end

  def index_params
    { series_id: @user_with_podcasts.series.first }
  end

  # INDEX

  test "should return valid json user podcats on user_id param" do
    get :index, params: { user_id: @user_with_podcasts.id }
    podcasts = @user_with_podcasts.podcasts
    podcasts_response = json_response[:data]
    assert_not_nil podcasts_response
    assert_equal podcasts.count, podcasts_response.count

    podcasts_response.each do |response|
      assert @user_with_podcasts.podcast_ids.include? response[:id].to_i
    end

    assert_response 200
  end

  test "should return published podcasts filtered by title on title param" do
    podcast_ids = []
    3.times do |i|
      podcast_attributes = FactoryGirl.attributes_for :published_podcast
      podcast_attributes[:title] = "Search Pattern Matched ##{i}"
      podcast_ids.push @podcasts.create(podcast_attributes).id
    end
    get :index, params: { title: "search pattern matched" }
    podcasts_response = json_response[:data]
    assert_not_nil podcasts_response
    assert_equal podcast_ids.count, podcasts_response.count

    podcast_ids 
    podcasts_response.each do |response|
      assert podcast_ids.include? response[:id].to_i
    end

    assert_response 200
  end

  # TODO: add test to verify receiving unpublished podcast when getting as owner

  test "should return published podcasts filtered by above end_time length" do
    get :index, params: { min_end_time: 86 }
    podcasts_response = json_response[:data]
    assert_equal Podcast.where(published: true).count, podcasts_response.count
    get :index, params: { min_end_time: 87 }
    podcasts_response = json_response[:data]
    assert_equal 0, podcasts_response.count
  end

  test "should return published podcasts filtered by below end_time length" do
    get :index, params: { max_end_time: 86 }
    podcasts_response = json_response[:data]
    assert_equal Podcast.where(published: true).count, podcasts_response.count
    get :index, params: { max_end_time: 85 }
    podcasts_response = json_response[:data]
    assert_equal 0, podcasts_response.count
  end

  #TODO: add aditinal podcasts with different endimes for more through testing
  test "should return valid json filtered by multiple filters" do 
    get :index, params: { min_end_time: 86, max_end_time: 86 }
    podcasts_response = json_response[:data]
    assert_equal Podcast.where(published: true).count, podcasts_response.count
    get :index, params: { min_end_time: 87, max_end_time: 89}
    podcasts_response = json_response[:data]
    assert_equal 0, podcasts_response.count
  end

  test "should return results filtered by series when both user_id and series_id is provided" do
    # NOTE: user has 3 podcasts, first series has 2
    series = @user_with_podcasts.series
    get :index, params: { series_id: series.first.id, user_id: @user_with_podcasts.id }
    assert_response 200
    podcasts_response = json_response[:data]
    assert_not_nil podcasts_response
    assert_equal series.first.published_podcasts.count, podcasts_response.count

    podcasts_response.each do |podcast|
      assert series.first.published_podcast_ids.include? podcast[:id].to_i
    end

    # alternative to above, maybe too convoluted
    #response_podcast_ids = podcasts_response.map {|x| x[:id].to_i }
    #assert (response_podcast_ids - series.first.published_podcast_ids).empty?
  end

  # CREATE
  
  test "create should reutrn errors on invalid series_id" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 podcast_file: open_podcast_file('piano-loop.mp3') }
    assert_no_difference '@series.podcasts.count' do
      post_as @user, :create, params: { series_id: -1, podcast: valid_podcast_attributes }
    end
    validate_response json_response[:errors], /series/, /is invalid/

    assert_response 422
  end

  test "create should return valid json on valid attributes with local auio file" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 podcast_file: open_podcast_file('piano-loop.mp3') }
    assert_difference '@series.podcasts.count', 1 do
      post_as @user, :create, params: { series_id: @series, podcast: valid_podcast_attributes }
    end
    podcast_response = json_response[:data]
    assert_not_nil podcast_response

    assert_response 201
  end

  # TODO: run generic resource tests on multiple valid_attributes
  test "create should return valid json on valid attributes with remote auio file" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 remote_podcast_file_url: "https://s3.amazonaws.com/podcastformetest/piano-loop.mp3" }
    assert_difference '@series.podcasts.count', 1 do
      post_as @user, :create, params: { series_id: @series, podcast: valid_podcast_attributes }
    end
    podcast_response = json_response[:data]
    assert_not_nil podcast_response
    assert_equal @user.podcasts.first.id, podcast_response[:id].to_i

    assert_response 201
  end

  # DESTROY

  test "destroy should destroy all dependent models" do
    timestamps = @podcasts.first.timestamps
    timestamps.create (FactoryGirl.attributes_for :timestamp, podcast_end_time: @podcasts.first.end_time)
    assert_difference '@podcasts.count', -1 do
      delete_as @user_with_podcasts, :destroy, params: { id: @podcasts.first }
    end
    assert_empty response.body

    assert_empty timestamps.reload

    assert_response 204
  end
end
