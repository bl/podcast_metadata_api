require 'test_helper'

class V1::PodcastsControllerTest < ActionController::TestCase

  def setup
    # create additional data
    2.times do
      FactoryGirl.create :user_with_podcasts
    end
    @user = FactoryGirl.create :user
    @user_with_podcasts = FactoryGirl.create :user_with_podcasts
    @podcasts = @user_with_podcasts.podcasts
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
    assert_match /Invalid podcast/, podcast_errors

    assert_response 403
  end

  # INDEX

  test "index should return valid json on all podcasts" do
    get :index
    podcasts_response = json_response[:data]
    assert_not_nil podcasts_response
    assert_equal Podcast.count, podcasts_response.count

    assert_response 200
  end

  # CREATE

  test "create should return json errors when not logged in" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 podcast_file: open_podcast_file('edenlarge.mp3') }
    assert_no_difference '@user.podcasts.count' do
      post :create, user_id: @user, podcast: valid_podcast_attributes
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /Not authenticated/, podcast_errors

    assert_response :unauthorized
  end

  test "should return json errors on create for non-logged in user" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 podcast_file: open_podcast_file('edenlarge.mp3') }
    log_in_as @user
    assert_no_difference '@user_with_podcasts.podcasts.count' do
      post :create, user_id: @user_with_podcasts, podcast: valid_podcast_attributes
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /Invalid user/, podcast_errors

    assert_response 403
  end

  test "create should return errors on invalid attribute" do
    invalid_podcast_attributes = { title: "New Podcast Name",
                                   podcast_file: "invalid_file" }
    log_in_as @user
    assert_no_difference '@user.podcasts.count' do
      post :create, user_id: @user, podcast: invalid_podcast_attributes
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /is not a valid audio file/, podcast_errors[:podcast_file].to_s

    assert_response 422
  end

  test "create should return valid json on valid attributes with local auio file" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 podcast_file: open_podcast_file('edenlarge.mp3') }
    log_in_as @user
    assert_difference '@user.podcasts.count', 1 do
      post :create, user_id: @user, podcast: valid_podcast_attributes
    end
    podcast_response = json_response[:data]
    assert_not_nil podcast_response

    assert_response 201
  end

  test "create should return valid json on valid attributes with remote auio file" do
    valid_podcast_attributes = { title: "New Podcast Name",
                                 remote_podcast_file_url: "http://www.magnac.com/sounds/edensmall.mp3" }
    log_in_as @user
    assert_difference '@user.podcasts.count', 1 do
      post :create, user_id: @user, podcast: valid_podcast_attributes
    end
    podcast_response = json_response[:data]
    assert_not_nil podcast_response
    assert_equal @user.podcasts.first.id, podcast_response[:id].to_i

    assert_response 201
  end

  # UPDATE

  test "update should return json errors when not logged-in" do
    valid_podcast_attributes = { title: "new title" }
    post :update, id: @podcasts.first, user_id: @user_with_podcasts, podcast: valid_podcast_attributes
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /Not authenticated/, podcast_errors
    
    assert_response :unauthorized
  end

  test "should return json errors when updating non-logged-in users podcast" do
    valid_podcast_attributes = { title: "new title" }
    log_in_as @user
    post :update, id: @podcasts.first, user_id: @user_with_podcasts, podcast: valid_podcast_attributes
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /Invalid user/, podcast_errors
    
    assert_response 403
  end

  test "update should return json errors when using invalid user_id" do
    valid_podcast_attributes = { title: "new title" }
    log_in_as @user_with_podcasts
    post :update, id: @podcasts.first, user_id: -1, podcast: valid_podcast_attributes
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /Invalid user/, podcast_errors
    
    assert_response 403
  end

  test "update should return json errors when using invalid podcast id" do
    valid_podcast_attributes = { title: "new title" }
    log_in_as @user_with_podcasts
    post :update, id: -1, user_id: @user_with_podcasts, podcast: valid_podcast_attributes
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /Invalid podcast/, podcast_errors
    
    assert_response 403
  end

  test "update should return json errors on invalid attributes" do
    valid_podcast_attributes = { title: " " }
    log_in_as @user_with_podcasts
    post :update, id: @podcasts.first, user_id: @user_with_podcasts, podcast: valid_podcast_attributes
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /can't be blank/, podcast_errors[:title].to_s
    
    assert_response 422
  end

  test "update should return valid json on valid attributes" do
    valid_podcast_attributes = { title: "new title" }
    log_in_as @user_with_podcasts
    post :update, id: @podcasts.first, user_id: @user_with_podcasts, podcast: valid_podcast_attributes
    podcast_response = json_response[:data]
    assert_not_nil podcast_response
    assert_equal valid_podcast_attributes[:title], @podcasts.first.reload.title
    assert_equal valid_podcast_attributes[:title], podcast_response[:attributes][:title]

    assert_response 200
  end

  # DESTROY

  test "should return authorization error when not logged in" do
    assert_no_difference '@podcasts.count' do
      delete :destroy, id: @podcasts.first, user_id: @user_with_podcasts
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /Not authenticated/, podcast_errors
  
    assert_response :unauthorized
  end

  test "should return json errors on invalid user id podcast destroy" do
    log_in_as @user_with_podcasts
    assert_no_difference '@podcasts.count' do
      delete :destroy, id: @podcasts.first, user_id: -1
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /Invalid user/, podcast_errors
  
    assert_response 403
  end

  test "should return json errors on invalid podcast id podcast destroy" do
    log_in_as @user_with_podcasts
    assert_no_difference '@podcasts.count' do
      delete :destroy, id: -1, user_id: @user_with_podcasts
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /Invalid podcast/, podcast_errors
  
    assert_response 403
  end

  test "should return json errors on deleting non-logged in users podcast" do
    log_in_as @user
    assert_no_difference '@podcasts.count' do
      delete :destroy, id: @podcasts.first, user_id: @user_with_podcasts
    end
    podcast_errors = json_response[:errors]
    assert_not_nil podcast_errors
    assert_match /Invalid user/, podcast_errors
  
    assert_response 403
  end

  test "should return empty payload on valid podcast destroy" do
    log_in_as @user_with_podcasts
    assert_difference '@podcasts.count', -1 do
      delete :destroy, id: @podcasts.first, user_id: @user_with_podcasts
    end
    assert_empty response.body

    assert_response 204
  end
end
