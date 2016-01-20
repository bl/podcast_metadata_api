require 'test_helper'

class Api::V1::SessionsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create :user
    include_default_accept_headers
  end

  # CREATE
  
  test "should return json errors on invalid user login" do
    invalid_login_attributes = { email:     "invalid_email.com",
                                 password:  "password" }
    post :create, session: invalid_login_attributes
    session_response = json_response[:Errors]
    assert_not_nil session_response
    assert_match /email_password/, session_response.first[:id].to_s
    assert_match /is invalid/, session_response.first.to_s
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
  end

  # DESTROY 
  
  test "should return header with success status on valid destroy" do
    # verify auth_token is created right after creation
    assert_not_nil @user.auth_token
    delete :destroy, id: @user.auth_token
    assert_empty response.body
    assert_nil @user.reload.auth_token
  end

# disabled rendering failure on session destroy action
#  test "should return json errors on invalid user id" do
#    post :destroy, id: -1
#    session_response = json_response[:errors]
#    assert_not_nil session_response
#    assert_match /Invalid user/, session_response.to_s
#  end
end
