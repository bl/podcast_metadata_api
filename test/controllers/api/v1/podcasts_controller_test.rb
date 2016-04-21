require 'test_helper'

class Api::V1::PodcastsControllerTest < ActionController::TestCase
  include ResourcesControllerTest
  include PublishableControllerTest

  def setup
    # create additional data
    2.times do
      misc_user = FactoryGirl.create :user_with_series
      misc_series = misc_user.series
      misc_series.each do |series|
        2.times do
          series.podcasts.create(FactoryGirl.attributes_for :published_podcast)
        end
      end
    end
    # user with empty series
    @user = (FactoryGirl.create :user_with_series, series_count: 1)
    @series = @user.series.first
    # user with series containing published podcasts (3 in first series, 1 in second series)
    @user_with_podcasts = FactoryGirl.create(:user_with_series, series_count: 3)
    series_with_podcasts = @user_with_podcasts.series.first
    3.times do
        series_with_podcasts.podcasts.create (FactoryGirl.attributes_for :published_podcast)
    end
    @user_with_podcasts.series.second.podcasts.create (FactoryGirl.attributes_for :published_podcast)
    @podcasts = series_with_podcasts.podcasts
    include_default_accept_headers

    # user with series containing unpublished podcasts (3 in first series, 1 in second series)
    @user_with_unpublished_podcasts = FactoryGirl.create(:user_with_series, series_count: 3)
    series_with_unpublished_podcasts = @user_with_unpublished_podcasts.series.first
    3.times do
        series_with_unpublished_podcasts.podcasts.create (FactoryGirl.attributes_for :podcast)
    end
    @user_with_unpublished_podcasts.series.second.podcasts.create (FactoryGirl.attributes_for :podcast)
    #@unpublished_podcasts = series_with_podcasts.podcasts
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
    get :index, { user_id: @user_with_podcasts.id }
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
    get :index, { title: "search pattern matched" }
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
    get :index, { min_end_time: 86 }
    podcasts_response = json_response[:data]
    assert_equal Podcast.where(published: true).count, podcasts_response.count
    get :index, { min_end_time: 87 }
    podcasts_response = json_response[:data]
    assert_equal 0, podcasts_response.count
  end

  test "should return published podcasts filtered by below end_time length" do
    get :index, { max_end_time: 86 }
    podcasts_response = json_response[:data]
    assert_equal Podcast.where(published: true).count, podcasts_response.count
    get :index, { max_end_time: 85 }
    podcasts_response = json_response[:data]
    assert_equal 0, podcasts_response.count
  end

  #TODO: add aditinal podcasts with different endimes for more through testing
  test "should return valid json filtered by multiple filters" do 
    get :index, { min_end_time: 86, max_end_time: 86 }
    podcasts_response = json_response[:data]
    assert_equal Podcast.where(published: true).count, podcasts_response.count
    get :index, { min_end_time: 87, max_end_time: 89}
    podcasts_response = json_response[:data]
    assert_equal 0, podcasts_response.count
  end

  # CREATE
  
  test "create should reutrn errors on invalid series_id" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 podcast_file: open_podcast_file('piano-loop.mp3') }
    assert_no_difference '@series.podcasts.count' do
      post_as @user, :create, series_id: -1, podcast: valid_podcast_attributes
    end
    validate_response json_response[:errors], /series/, /is invalid/

    assert_response 422
  end

  test "create should return valid json on valid attributes with local auio file" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 podcast_file: open_podcast_file('piano-loop.mp3') }
    assert_difference '@series.podcasts.count', 1 do
      post_as @user, :create, series_id: @series, podcast: valid_podcast_attributes
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
      post_as @user, :create, series_id: @series, podcast: valid_podcast_attributes
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
      delete_as @user_with_podcasts, :destroy, id: @podcasts.first
    end
    assert_empty response.body

    assert_empty timestamps.reload

    assert_response 204
  end
end
