require 'test_helper'

class V1::UsersControllerTest < ActionController::TestCase

  def setup
    # create additional data, verify more than record in db
    5.times do
      FactoryGirl.create :user
    end
    @user = FactoryGirl.create :user
    @other_user = FactoryGirl.create :user
    include_default_accept_headers
  end

  # SHOW

  test "should return valid json on user get" do
    get :show, id: @user
    user_response = json_response[:data]
    assert_not_nil user_response
    assert @user.id, user_response[:attributes][:id]
    
    assert_response 200
  end

  # INDEX
  
  test "should return valid json on all users" do
    get :index
    user_response = json_response[:data]
    assert_not_nil user_response
    assert_equal User.all.count, user_response.count
    
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
    assert_match /is invalid/, user_errors[:email].to_s
    
    assert_response 422
  end

  test "should return valid json on valid user attributes" do
    valid_user_attributes = FactoryGirl.attributes_for :user
    assert_difference 'User.count', 1 do
      post :create, user: valid_user_attributes
    end
    user_response = json_response[:data]
    assert_not_nil user_response
    assert_equal valid_user_attributes[:email], user_response[:attributes][:email]
    
    assert_response 200
  end

  # UPDATE

  test "update should return authorization error when not logged in" do
    update_user_attributes = { name: "New Name" }
    post :update, id: @user, user: update_user_attributes
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /Not authenticated/, user_errors.to_s
    
    assert_response :unauthorized
  end

  test "should return json errors on invalid user id" do
    update_user_attributes = { email: "new_email@example.com" }
    log_in_as @user
    post :update, id: -1, user: update_user_attributes
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /Invalid user/, user_errors.to_s
    
    assert_response 403
  end

  test "should return json errors on other user id update" do
    update_user_attributes = { email: "new_email@example.com" }
    log_in_as @user
    post :update, id: @other_user, user: update_user_attributes
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /Invalid user/, user_errors.to_s
    
    assert_response 403
  end

  test "should return valid json on valid user update" do
    update_user_attributes = { name: "New Name", email: "new_email@example.com" }
    log_in_as @user
    post :update, id: @user, user: update_user_attributes
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
    post :update, id: @user, user: update_user_attributes
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
    assert_match /Not authenticated/, user_errors.to_s
    
    assert_response :unauthorized
  end

  test "should return json errors on invalid user id destroy" do
    log_in_as @user
    assert_no_difference 'User.count' do
      delete :destroy, id: -1
    end
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /Invalid user/, user_errors.to_s
    
    assert_response 403
  end

  test "should return json errors on other user id destroy" do
    log_in_as @user
    assert_no_difference 'User.count' do
      delete :destroy, id: @other_user
    end
    user_errors = json_response[:errors]
    assert_not_nil user_errors
    assert_match /Invalid user/, user_errors.to_s
    
    assert_response 403
  end
  
  test "should return empty payload on valid user destroy" do
    log_in_as @user
    assert_difference 'User.count', -1 do
      delete :destroy, id: @user
    end
    assert_empty response.body
    
    assert_response 204
  end
end
