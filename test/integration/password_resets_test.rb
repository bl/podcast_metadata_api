require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    host! 'api.lvh.me'

    @user = FactoryGirl.create :activated_user
  end

  # SHOW
  # TODO: fail test cases for SHOW action (EXACT same cases as create/update actions)

  test "web api client successfully requests if email and reset_token are valid" do
    # create reset_token
    post api_password_resets_path(email: @user.email)
    user = assigns(:user)

    get api_password_reset_path(user.reset_token, email: user.email)
    assert_response 200
    assert_empty response.body
  end

  # CREATE (request password reset email)

  test "user attempts to request password reset with invalid user email" do
    post api_password_resets_path(email: "invalid_email@example.com")
    assert_response 422
    validate_response json_response[:errors], /email/, /is invalid/
  end

  test "user attempts to request password reset with non-activated user" do
    non_activated_user = FactoryGirl.create :user
    post api_password_resets_path(email: non_activated_user.email)
    assert_response 403
    validate_response json_response[:errors], /user/, /has not been activated/
  end

  test "user successfully requests password reset with valid user email" do
    # verify email delivered is correct
    perform_enqueued_jobs do
      post api_password_resets_path(email: @user.email)
      reset_email = ActionMailer::Base.deliveries.last
      assert_match CGI::escape(@user.email), reset_email.body.encoded
    end
    assert_response 201
    assert_empty response.body
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
  end

  # UPDATE (update password)

  test "user attempts to submit password update with invalid reset token" do
    valid_reset_params = { password: "foobar",
                           password_confirmation: "foobar" }
    patch api_password_reset_path "invalid_token", email: @user.email, user: valid_reset_params
    validate_response json_response[:errors], /reset_token/, /is invalid/
  end

  test "user attempts to submit password update with invalid email" do
    # create reset_token
    post api_password_resets_path email: @user.email
    user = assigns(:user)

    valid_reset_params = { password: "foobar",
                             password_confirmation: "foobar" }
    patch api_password_reset_path user.reset_token, email: "invalid_email@example.com", user: valid_reset_params
    assert_response 422
    validate_response json_response[:errors], /email/, /is invalid/
  end

  test "user attempts to submit password update with invalid password" do
    # create reset_token
    post api_password_resets_path email: @user.email
    user = assigns(:user)

    invalid_reset_params = { password: "foobar",
                             password_confirmation: "barfoo" }
    patch api_password_reset_path user.reset_token, email: user.email, user: invalid_reset_params
    assert_response 422
    validate_response json_response[:errors], /password_confirmation/, /doesn't match Password/
  end

  test "user attempts to submit password update with expired reset token" do
    # create reset_token
    post api_password_resets_path email: @user.email
    user = assigns(:user)
    # expire reset_token
    user.update_attribute(:reset_sent_at, 3.hours.ago)

    valid_reset_params = { password: "foobar",
                           password_confirmation: "foobar" }
    patch api_password_reset_path user.reset_token, email: user.email, user: valid_reset_params
    assert_response 422
    validate_response json_response[:errors], /reset_token/, /has expired/
  end

  test "user successfully submits password update with valid password" do
    # create reset_token
    post api_password_resets_path email: @user.email
    user = assigns(:user)

    valid_reset_params = { password: "foobar",
                           password_confirmation: "foobar" }
    patch api_password_reset_path user.reset_token, email: user.email, user: valid_reset_params
    assert_response 200
    reset_response = json_response[:data]
    assert_not_nil reset_response
    assert_equal user.id, reset_response[:id].to_i

    # verify reset attributes are cleared upon valid password reset
    user.reload
    assert_nil user.reset_digest
    assert_nil user.reset_sent_at
  end
end
