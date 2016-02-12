require 'test_helper'

class UsersActivationTest < ActionDispatch::IntegrationTest
  def setup
    host! 'api.lvh.me'

    # create user that is not (yet) activated
    valid_user_attributes = FactoryGirl.attributes_for :user
    post api_users_path, user: valid_user_attributes
    assert_response 201

    # get user created above
    @user = assigns(:user)
  end

  # NOTE: test does not directly call account_activations controller but tests that non-activated users
  # are unable to access any resources that require authentication
  test "non activated user should fail token authentication" do

    #api_authorization_header @user.auth_token
    #headers.merge! 'Authorization' => @user.auth_token
    headers = { 'Authorization' => @user.auth_token }
    valid_article_attributes = FactoryGirl.attributes_for :article
    assert_no_difference '@user.articles.count' do
      post api_articles_path, { article: valid_article_attributes }, headers
    end
    assert_response 403
    article_errors = json_response[:errors]
    assert_match /user/, article_errors.first[:id].to_s
    assert_match /has not been activated/, article_errors.first[:detail].to_s
  end

  test "user attemptes to activate with invalid user email" do
    get edit_api_account_activation_path(@user.activation_token, email: "invalid_email@example.com")
    activations_errors = json_response[:errors]
    assert_not_nil activations_errors
    assert_response 422
    assert_match /activation_link/, activations_errors.first[:id].to_s
    assert_match /is invalid/, activations_errors.first.to_s
  end

  test "user attempts to activate with invalid activation token" do
    get edit_api_account_activation_path("invalid_token", email: @user.email)
    activations_errors = json_response[:errors]
    assert_not_nil activations_errors
    assert_response 422
    assert_match /activation_link/, activations_errors.first[:id].to_s
    assert_match /is invalid/, activations_errors.first.to_s
  end

  test "already activated user attempts to activate again" do
    activated_user = FactoryGirl.create :activated_user
    get edit_api_account_activation_path(activated_user.activation_token, email: activated_user.email)
    activations_errors = json_response[:errors]
    assert_not_nil activations_errors
    assert_response 422
    assert_match /activation_link/, activations_errors.first[:id].to_s
    assert_match /is invalid/, activations_errors.first.to_s
  end

  test "user registers and acivates account with valid activation token and email" do
    # NOTE: it appears that the following forms are BOTH valid
    # get edit_api_account_activation_path(@user.activation_token), { email: @user.email }
    # get edit_api_account_activation_path(@user.activation_token, email: @user.email)

    get edit_api_account_activation_path(@user.activation_token, email: @user.email)
    assert_response 200
    activations_response = json_response[:data]
    assert_not_nil activations_response
    assert_equal @user.id, activations_response[:id].to_i
    assert_equal @user.name, activations_response[:attributes][:name]
    assert_equal @user.email, activations_response[:attributes][:email]

    headers = { 'Authorization' => @user.auth_token }
    valid_article_attributes = FactoryGirl.attributes_for :article
    assert_difference '@user.articles.count', 1 do
      post api_articles_path, { article: valid_article_attributes }, headers
    end
    assert_response 201
    article_response = json_response[:data]
  end
end
