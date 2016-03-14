require 'test_helper'

class Api::V1::UsersControllerTest < ActionController::TestCase

  def setup
    # create additional data, verify more than record in db
    5.times do
      FactoryGirl.create :activated_user
    end
    @user = FactoryGirl.create :activated_user
    @other_user = FactoryGirl.create :activated_user
    @user_with_series = FactoryGirl.create :user_with_series
    include_default_accept_headers
  end

  # SHOW

  test "should return valid json on user get" do
    get :show, id: @user
    user_response = json_response[:data]
    assert_not_nil user_response
    assert @user.id, user_response[:attributes][:id]
    assert_not user_response[:attributes][:auth_token]
    
    assert_response 200
  end

  test "should return json errors on invalid user id get" do
    get :show, id: -1
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /user/, user_errors.first[:id].to_s
    assert_match /is invalid/, user_errors.first[:detail].to_s

    assert_response 422
  end

  test "should return json errors on non activated user id get" do
    # create non-activated user
    non_activated_user = FactoryGirl.create :user
    get :show, id: non_activated_user
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /user/, user_errors.first[:id].to_s
    assert_match /is invalid/, user_errors.first[:detail].to_s

    assert_response 422
  end

  test "should return user json and series relationship on valid user get" do
    get :show, id: @user_with_series
    user_response = json_response[:data]
    assert_not_nil user_response
    user_series_response = user_response[:relationships][:series][:data]
    assert_not_nil user_series_response
    assert_equal @user_with_series.series.count, user_series_response.count
  end

  # INDEX
  
  test "should return valid json on all activated users" do
    # create non-activated user
    non_activated_user = FactoryGirl.create :user
    get :index
    user_response = json_response[:data]
    assert_not_nil user_response
    assert_equal User.where(activated: true).count, user_response.count
    assert_not User.where(activated: true).include? non_activated_user
    
    assert_response 200
  end

  # CREATE

  test "should return errors on invalid email attribute" do
    invalid_user_attributes = { name:   "James",
                                email:  "invalid_email.com",
                                password:              "password",
                                password_confirmation: "password" }
    assert_no_difference 'User.count' do
      post :create, user: invalid_user_attributes
    end
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /email/, user_errors.first[:id].to_s
    assert_match /is invalid/, user_errors.first[:detail].to_s
    
    assert_response 422
  end

  test "should return valid json on valid user attributes" do
    valid_user_attributes = FactoryGirl.attributes_for :user
    assert_difference 'User.count', 1 do
      post :create, user: valid_user_attributes
    end
    assert_empty response.body
    
    assert_response 201
  end

  # UPDATE

  test "update should return authorization error when not logged in" do
    update_user_attributes = { name: "New Name" }
    patch :update, id: @user, user: update_user_attributes
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /user/, user_errors.first[:id].to_s
    assert_match /not authenticated/, user_errors.first.to_s
    
    assert_response :unauthorized
  end

  test "should return json errors on invalid user id" do
    update_user_attributes = { email: "new_email@example.com" }
    log_in_as @user
    patch :update, id: -1, user: update_user_attributes
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /user/, user_errors.first[:id].to_s
    assert_match /is invalid/, user_errors.first.to_s
    
    assert_response 422
  end

  test "should return json errors on other user id update" do
    update_user_attributes = { email: "new_email@example.com" }
    log_in_as @user
    patch :update, id: @other_user, user: update_user_attributes
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /user/, user_errors.first[:id].to_s
    assert_match /is invalid/, user_errors.first.to_s
    
    assert_response 422
  end

  test "should return valid json on valid user update" do
    update_user_attributes = { name: "New Name", email: "new_email@example.com" }
    log_in_as @user
    patch :update, id: @user, user: update_user_attributes
    user_response = json_response[:data]
    assert_not_nil user_response
    @user.reload
    assert_equal @user.id, user_response[:id].to_i
    assert_equal @user.name, user_response[:attributes][:name]
    assert_equal @user.email, user_response[:attributes][:email]
    
    assert_response 200
  end

  test "should return valid json on valid user password update" do
    new_password = "123456"
    log_in_as @user
    update_user_attributes = { password: new_password, password_confirmation: new_password }
    patch :update, id: @user, user: update_user_attributes
    user_response = json_response[:data]
    assert_not_nil user_response
    @user.reload
    assert_equal @user.id, user_response[:id].to_i
    assert @user.authenticated? :password, new_password
    
    assert_response 200
  end

  # DESTROY

  test "destroy should return authorization error when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /user/, user_errors.first[:id].to_s
    assert_match /not authenticated/, user_errors.first.to_s
    
    assert_response :unauthorized
  end

  test "should return json errors on invalid user id destroy" do
    log_in_as @user
    assert_no_difference 'User.count' do
      delete :destroy, id: -1
    end
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /user/, user_errors.first[:id].to_s
    assert_match /is invalid/, user_errors.first.to_s
    
    assert_response 422
  end

  test "should return json errors on other user id destroy" do
    log_in_as @user
    assert_no_difference 'User.count' do
      delete :destroy, id: @other_user
    end
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /user/, user_errors.first[:id].to_s
    assert_match /is invalid/, user_errors.first.to_s
    
    assert_response 422
  end
  
  test "should return empty payload on valid user destroy" do
    log_in_as @user
    assert_difference 'User.count', -1 do
      delete :destroy, id: @user
    end
    assert_empty response.body
    
    assert_response 204
  end

  test "destroy should destroy all dependent series" do
    log_in_as @user_with_series
    series = @user_with_series.series
    assert_difference 'User.count', -1 do
      delete :destroy, id: @user_with_series
    end

    assert_empty series
    
    assert_response 204
  end

  test "destroy should destroy all dependent articles" do
    user_with_articles = FactoryGirl.create :user_with_unpublished_articles
    articles = user_with_articles.articles
    log_in_as user_with_articles
    assert_difference 'User.count', -1 do
      delete :destroy, id: user_with_articles
    end

    assert_empty articles
    
    assert_response 204
  end
end
