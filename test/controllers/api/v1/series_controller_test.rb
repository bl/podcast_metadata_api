require 'test_helper'

class Api::V1::SeriesControllerTest < ActionController::TestCase
  def setup
    # create additional data
    2.times do
      FactoryGirl.create :user_with_series
    end
    @user = FactoryGirl.create :activated_user
    @user_with_series = FactoryGirl.create :user_with_series
    @series = @user_with_series.series
    include_default_accept_headers
  end

  # SHOW
  
  test "show should return valid json on series get" do
    get :show, id: @series.first
    series_response = json_response[:data]
    assert_not_nil series_response
    assert_equal @series.first.id, series_response[:id].to_i

    assert_response 200
  end

  test "show should return json errors on invalid series id get" do
    get :show, id: -1
    series_errors = json_response[:errors]
    assert_not_nil series_errors
    assert_match /series/, series_errors.first[:id].to_s
    assert_match /is invalid/, series_errors.first[:detail].to_s

    assert_response 403
  end

  # INDEX
  
  test "index should return valid json on all series" do
    get :index
    series_response = json_response[:data]
    assert_not_nil series_response
    assert_equal Series.count, series_response.count

    assert_response 200
  end

  test "index should return user series with user_id param" do
    get :index, { user_id: @user_with_series.id }
    series_response = json_response[:data]
    assert_not_nil series_response
    assert_equal @series.count, series_response.count
    series_response.each do |res|
      assert @user_with_series.series_ids.include? res[:id].to_i
    end

    assert_response 200
  end

  # CREATE

  test "create should return json errors when not logged in" do
    valid_series_attributes = { title: "Hipster NYC Underground Jungle Boogie Break Beat Hits",
                                description: "A podcast discussing the best in jungle boogie break beat" }
    assert_no_difference '@user.series.count' do
      post :create, series: valid_series_attributes
    end
    series_errors = json_response[:errors]
    assert_not_nil series_errors
    assert_match /user/, series_errors.first[:id].to_s
    assert_match /not authenticated/, series_errors.first[:detail].to_s

    assert_response :unauthorized
  end

  test "create should not create series on non-logged in users" do
    valid_series_attributes = { title: "Hipster NYC Underground Jungle Boogie Break Beat Hits",
                                description: "A podcast discussing the best in jungle boogie break beat" }
    log_in_as @user
    before_create_count = @user.series.count
    assert_no_difference '@series.count' do
      post :create, series: valid_series_attributes
    end
    series_response = json_response[:data]
    assert_not_nil series_response
    assert_equal before_create_count+1, @user.reload.series.count

    assert_response 201
  end

  test "create should return json errors on invalid attribtues" do
    invalid_series_attributes = { title: " ",
                                description: "A podcast discussing the best in jungle boogie break beat" }
    log_in_as @user
    assert_no_difference '@user.series.count' do
      post :create, series: invalid_series_attributes
    end
    series_errors = json_response[:errors]
    assert_not_nil series_errors
    assert_match /title/, series_errors.first[:id].to_s
    assert_match /can't be blank/, series_errors.first[:detail].to_s

    assert_response 422
  end

  test "create should return valid json on valid attributes" do
    valid_series_attributes = { title: "Hipster NYC Underground Jungle Boogie Break Beat Hits",
                                description: "A podcast discussing the best in jungle boogie break beat" }
    log_in_as @user
    assert_difference '@user.series.count', 1 do
      post :create, series: valid_series_attributes
    end
    series_response = json_response[:data]
    assert_not_nil series_response
    assert_equal @user.series.first.id, series_response[:id].to_i

    assert_response 201
  end

  # UPDATE

  test "update should return json errors when not logged-in" do
    valid_series_attributes = { title: "new title", description: "new description" }
    patch :update, id: @series.first, series: valid_series_attributes
    series_errors = json_response[:errors]
    assert_not_nil series_errors
    assert_match /user/, series_errors.first[:id].to_s
    assert_match /not authenticated/, series_errors.first[:detail].to_s
    
    assert_response :unauthorized
  end

  test "should return json errors when updating non-logged-in users series" do
    valid_series_attributes = { title: "new title", description: "new description" }
    log_in_as @user
    patch :update, id: @series.first, series: valid_series_attributes
    series_errors = json_response[:errors]
    assert_not_nil series_errors
    assert_match /series/, series_errors.first[:id].to_s
    assert_match /is invalid/, series_errors.first[:detail].to_s

    assert_response 403
  end

  test "update should return json errors when using invalid series id" do
    valid_series_attributes = { title: "new title", description: "new description" }
    log_in_as @user_with_series
    patch :update, id: -1, series: valid_series_attributes
    series_errors = json_response[:errors]
    assert_not_nil series_errors
    assert_match /series/, series_errors.first[:id].to_s
    assert_match /is invalid/, series_errors.first[:detail].to_s

    assert_response 403
  end

  test "update should return json errors on invalid attributes" do
    invalid_series_attributes = { title: " ", description: "new description" }
    log_in_as @user_with_series
    patch :update, id: @series.first, series: invalid_series_attributes
    series_errors = json_response[:errors]
    assert_not_nil series_errors
    assert_match /title/, series_errors.first[:id].to_s
    assert_match /can't be blank/, series_errors.first[:detail].to_s

    assert_response 422
  end

  test "update should return valid json on valid attributes" do
    valid_series_attributes = { title: "new title", description: "new description" }
    log_in_as @user_with_series
    patch :update, id: @series.first, series: valid_series_attributes
    series_response = json_response[:data]
    assert_not_nil series_response
    assert_equal valid_series_attributes[:title], @series.first.reload.title
    assert_equal valid_series_attributes[:title], series_response[:attributes][:title]
    
    assert_response 200
  end

  # DESTROY
  test "should return authorization error when not logged in" do
    assert_no_difference '@series.count' do
      delete :destroy, id: @series.first
    end
    series_errors = json_response[:errors]
    assert_not_nil series_errors
    assert_match /user/, series_errors.first[:id].to_s
    assert_match /not authenticated/, series_errors.first[:detail].to_s
  
    assert_response :unauthorized
  end

  test "should return json errors on invalid series id series destroy" do
    log_in_as @user_with_series
    assert_no_difference '@series.count' do
      delete :destroy, id: -1
    end
    series_errors = json_response[:errors]
    assert_not_nil series_errors
    assert_match /series/, series_errors.first[:id].to_s
    assert_match /is invalid/, series_errors.first[:detail].to_s
  
    assert_response 403
  end

  test "should return json errors on deleting non-logged in users series" do
    log_in_as @user
    assert_no_difference '@series.count' do
      delete :destroy, id: @series.first
    end
    series_errors = json_response[:errors]
    assert_not_nil series_errors
    assert_match /series/, series_errors.first[:id].to_s
    assert_match /is invalid/, series_errors.first[:detail].to_s
  
    assert_response 403
  end

  test "should return empty payload on valid series destroy" do
    log_in_as @user_with_series
    assert_difference '@series.count', -1 do
      delete :destroy, id: @series.first
    end
    assert_empty response.body

    assert_response 204
  end

  test "destroy should destroy all series dependent podcasts" do
    podcasts = @series.first.podcasts
    log_in_as @user_with_series
    assert_difference 'Series.count', -1 do
      delete :destroy, id: @series.first
    end

    assert_empty podcasts
    
    assert_response 204
  end

end
