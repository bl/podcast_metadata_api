require 'test_helper'

class Api::V1::SessionsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create :activated_user
    include_default_accept_headers
    @non_activated_user = (FactoryGirl.create :user)
  end

  # CREATE
  
  test "should return json errors on invalid user login" do
    invalid_login_attributes = { email:     "invalid_email.com",
                                 password:  "password" }
    post :create, session: invalid_login_attributes
    session_response = json_response[:errors]
    assert_not_nil session_response
    assert_match /email_password/, session_response.first[:id].to_s
    assert_match /is invalid/, session_response.first.to_s

    assert_response 422
  end

  test "should return json errors on login on non activated user" do
    valid_login_attributes = { email:     @non_activated_user.email,
                               password:  "password" }
    post :create, session: valid_login_attributes
    session_response = json_response[:errors]
    assert_not_nil session_response
    assert_match /user/, session_response.first[:id].to_s
    assert_match /has not been activated/, session_response.first.to_s

    assert_response 403
  end

  test "should return valid json on valid user login" do
    old_token = @user.auth_token
    valid_login_attributes = { email:     @user.email,
                               password:  "password" }
    post :create, session: valid_login_attributes
    session_response = json_response[:data]
    assert_not_nil session_response
    @user.reload
    assert_equal @user.auth_token, session_response[:attributes][:auth_token]
    assert_not_equal old_token, @user.auth_token

    assert_response 200
  end

  # DESTROY 
  
  test "should return header with success status on valid destroy" do
    # verify auth_token is created right after creation
    assert_not_nil @user.auth_token
    delete :destroy, id: @user.auth_token
    assert_empty response.body
    assert_nil @user.reload.auth_token

    assert_response 204
  end

# disabled rendering failure on session destroy action
#  test "should return json errors on invalid user id" do
#    post :destroy, id: -1
#    session_response = json_response[:errors]
#    assert_not_nil session_response
#    assert_match /Invalid user/, session_response.to_s
#  end
end
