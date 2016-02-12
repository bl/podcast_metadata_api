require 'test_helper'

class Api::V1::PodcastsControllerTest < ActionController::TestCase

  def setup
    # create additional data
    2.times do
      misc_user = FactoryGirl.create :user_with_series
      misc_series = misc_user.series
      misc_series.each do |series|
        2.times do
          series.podcasts.create(FactoryGirl.attributes_for :podcast)
        end
      end
    end
    # user with empty series
    @user = (FactoryGirl.create :user_with_series, series_count: 1)
    @series = @user.series.first
    # user with series containing podcasts (3 in first series, 1 in second series)
    @user_with_series = FactoryGirl.create(:user_with_series, series_count: 3)
    @series_with_podcasts = @user_with_series.series.first
    3.times do
        @series_with_podcasts.podcasts.create (FactoryGirl.attributes_for :podcast)
    end
    @user_with_series.series.second.podcasts.create (FactoryGirl.attributes_for :podcast)
    @podcasts = @series_with_podcasts.podcasts
    include_default_accept_headers
  end

  # SHOW

  test "should return valid json on podcast get" do
    get :show, id: @podcasts.first
    podcast_response = json_response[:data]
    assert_not_nil podcast_response
    assert_equal @podcasts.first.id, podcast_response[:id].to_i

    assert_response 200
  end

  test "should return errors on invalid podcast id get" do
    get :show, id: -1
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /podcast/, podcast_errors.first[:id].to_s
    assert_match /is invalid/, podcast_errors.first[:detail].to_s

    assert_response 422
  end

  # INDEX

  test "index should return valid json on all podcasts" do
    get :index
    podcasts_response = json_response[:data]
    assert_not_nil podcasts_response
    assert_equal Podcast.count, podcasts_response.count

    assert_response 200
  end

  test "should return valid json user podcats on user_id param" do
    get :index, { user_id: @user_with_series.id }
    podcasts = @user_with_series.podcasts
    podcasts_response = json_response[:data]
    assert_not_nil podcasts_response
    assert_equal podcasts.count, podcasts_response.count

    podcasts_response.each do |response|
      assert @user_with_series.podcast_ids.include? response[:id].to_i
    end

    assert_response 200
  end

  test "should return valid json user podcats on series_id param" do
    get :index, { series_id: @series_with_podcasts.id }
    podcasts = @series_with_podcasts.podcasts
    podcasts_response = json_response[:data]
    assert_not_nil podcasts_response
    assert_equal podcasts.count, podcasts_response.count

    podcasts_response.each do |response|
      assert @user_with_series.podcast_ids.include? response[:id].to_i
    end

    assert_response 200
  end

  test "should return valid json filtered by title on title param" do
    podcast_ids = []
    3.times do |i|
      podcast_attributes = FactoryGirl.attributes_for :podcast
      podcast_attributes[:title] = "Search Pattern Matched ##{i}"
      podcast_ids.push @series_with_podcasts.podcasts.create(podcast_attributes).id
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

  test "should return valid json filtered by above end_time length" do
    get :index, { min_end_time: 86 }
    podcasts_response = json_response[:data]
    assert_equal Podcast.count, podcasts_response.count
    get :index, { min_end_time: 87 }
    podcasts_response = json_response[:data]
    assert_equal 0, podcasts_response.count
  end

  test "should return valid json filtered by below end_time length" do
    get :index, { max_end_time: 86 }
    podcasts_response = json_response[:data]
    assert_equal Podcast.count, podcasts_response.count
    get :index, { max_end_time: 85 }
    podcasts_response = json_response[:data]
    assert_equal 0, podcasts_response.count
  end

  #TODO: add aditinal podcasts with different endimes for more through testing
  test "should return valid json filtered by multiple filters" do 
    get :index, { min_end_time: 86, max_end_time: 86 }
    podcasts_response = json_response[:data]
    assert_equal Podcast.count, podcasts_response.count
    get :index, { min_end_time: 87, max_end_time: 89}
    podcasts_response = json_response[:data]
    assert_equal 0, podcasts_response.count
  end

  # CREATE

  test "create should return json errors when not logged in" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 podcast_file: open_podcast_file('piano-loop.mp3') }
    assert_no_difference '@series.podcasts.count' do
      post :create, series_id: @series, podcast: valid_podcast_attributes
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /user/, podcast_errors.first[:id].to_s
    assert_match /not authenticated/, podcast_errors.first[:detail].to_s

    assert_response :unauthorized
  end
  
  test "create should reutrn errors on invalid series_id" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 podcast_file: open_podcast_file('piano-loop.mp3') }
    log_in_as @user
    assert_no_difference '@series.podcasts.count' do
      post :create, series_id: -1, podcast: valid_podcast_attributes
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /series/, podcast_errors.first[:id].to_s
    assert_match /is invalid/, podcast_errors.first[:detail].to_s

    assert_response 422
  end

  test "create should return errors on invalid attribute" do
    invalid_podcast_attributes = { title: "New Podcast Name",
                                   podcast_file: "invalid_file" }
    log_in_as @user
    assert_no_difference '@series.podcasts.count' do
      post :create, series_id: @series, podcast: invalid_podcast_attributes
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /podcast_file/, podcast_errors.first[:id].to_s
    assert_match /is not a valid audio file/, podcast_errors.first[:detail].to_s

    assert_response 422
  end

  test "create should return valid json on valid attributes with local auio file" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 podcast_file: open_podcast_file('piano-loop.mp3') }
    log_in_as @user
    assert_difference '@series.podcasts.count', 1 do
      post :create, series_id: @series, podcast: valid_podcast_attributes
    end
    podcast_response = json_response[:data]
    assert_not_nil podcast_response

    assert_response 201
  end

  test "create should return valid json on valid attributes with remote auio file" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 remote_podcast_file_url: "http://www.magnac.com/sounds/edensmall.mp3" }
    log_in_as @user
    assert_difference '@series.podcasts.count', 1 do
      post :create, series_id: @series, podcast: valid_podcast_attributes
    end
    podcast_response = json_response[:data]
    assert_not_nil podcast_response
    assert_equal @user.podcasts.first.id, podcast_response[:id].to_i

    assert_response 201
  end

  # UPDATE

  test "update should return json errors when not logged-in" do
    valid_podcast_attributes = { title: "new title" }
    patch :update, id: @podcasts.first, podcast: valid_podcast_attributes
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /user/, podcast_errors.first[:id].to_s
    assert_match /not authenticated/, podcast_errors.first[:detail].to_s
    
    assert_response :unauthorized
  end

  test "should return json errors when updating non-logged-in users podcast" do
    valid_podcast_attributes = { title: "new title" }
    log_in_as @user
    patch :update, id: @podcasts.first, podcast: valid_podcast_attributes
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /podcast/, podcast_errors.first[:id].to_s
    assert_match /is invalid/, podcast_errors.first[:detail].to_s
    
    assert_response 422
  end

  test "update should return json errors when using invalid podcast id" do
    valid_podcast_attributes = { title: "new title" }
    log_in_as @user_with_series
    patch :update, id: -1, podcast: valid_podcast_attributes
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /podcast/, podcast_errors.first[:id].to_s
    assert_match /is invalid/, podcast_errors.first[:detail].to_s
    
    assert_response 422
  end

  test "update should return json errors on invalid attributes" do
    valid_podcast_attributes = { title: " " }
    log_in_as @user_with_series
    patch :update, id: @podcasts.first, podcast: valid_podcast_attributes
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /title/, podcast_errors.first[:id].to_s
    assert_match /can't be blank/, podcast_errors.first[:detail].to_s
    
    assert_response 422
  end

  test "update should return valid json on valid attributes" do
    valid_podcast_attributes = { title: "new title" }
    log_in_as @user_with_series
    patch :update, id: @podcasts.first, podcast: valid_podcast_attributes
    podcast_response = json_response[:data]
    assert_not_nil podcast_response
    assert_equal valid_podcast_attributes[:title], @podcasts.first.reload.title
    assert_equal valid_podcast_attributes[:title], podcast_response[:attributes][:title]

    assert_response 200
  end

  # DESTROY

  test "should return authorization error when not logged in" do
    assert_no_difference '@podcasts.count' do
      delete :destroy, id: @podcasts.first
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /user/, podcast_errors.first[:id].to_s
    assert_match /not authenticated/, podcast_errors.first[:detail].to_s
  
    assert_response :unauthorized
  end

  test "should return json errors on invalid podcast id podcast destroy" do
    log_in_as @user_with_series
    assert_no_difference '@podcasts.count' do
      delete :destroy, id: -1
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /podcast/, podcast_errors.first[:id].to_s
    assert_match /is invalid/, podcast_errors.first[:detail].to_s
  
    assert_response 422
  end

  test "should return json errors on deleting non-logged in users podcast" do
    log_in_as @user
    assert_no_difference '@podcasts.count' do
      delete :destroy, id: @podcasts.first
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /podcast/, podcast_errors.first[:id].to_s
    assert_match /is invalid/, podcast_errors.first[:detail].to_s
  
    assert_response 422
  end

  test "should return empty payload on valid podcast destroy" do
    log_in_as @user_with_series
    assert_difference '@podcasts.count', -1 do
      delete :destroy, id: @podcasts.first
    end
    assert_empty response.body

    assert_response 204
  end

  test "destroy should destroy all dependent models" do
    timestamps = @podcasts.first.timestamps
    timestamps.create (FactoryGirl.attributes_for :timestamp, podcast_end_time: @podcasts.first.end_time)
    log_in_as @user_with_series
    assert_difference '@podcasts.count', -1 do
      delete :destroy, id: @podcasts.first
    end
    assert_empty response.body

    assert_empty timestamps.reload

    assert_response 204
  end
end
