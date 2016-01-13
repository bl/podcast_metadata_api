require 'test_helper'

class V1::ArticlesControllerTest < ActionController::TestCase

  def setup
    # user with articles
    @user_with_articles = FactoryGirl.create :user_with_articles
    @articles = @user_with_articles.articles

    # user without articles
    @user = FactoryGirl.create :user
  end

  # SHOW

  test "get should return valid json on article" do
    get :show, id: @articles.first
    article_response = json_response[:data]
    assert_not_nil article_response
    assert_equal  @articles.first.id, article_response[:id].to_i

    assert_response 200
  end

  test "get should return json errors on invalid article id" do
    get :show, id: -1
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /Invalid article/, article_errors
    
    assert_response 403
  end

  # INDEX

  test "index should return json of all articles" do
    get :index
    articles_response = json_response[:data]
    assert_not_nil articles_response
    assert_equal Article.count, articles_response.count

    assert_response 200
  end

  # CREATE

  test "create should return json errors when not logged in" do
    valid_article_attributes = { content: "Valid text content\n newline, <p>html tags</p>" }
    assert_no_difference '@user.articles.count' do
      post :create, article: valid_article_attributes
    end
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /Not authenticated/, article_errors

    assert_response :unauthorized
  end

  test "create should only add article to logged in users article" do
    valid_article_attributes = { content: "Valid text content\n newline, <p>html tags</p>" }
    log_in_as @user
    before_create_count = @user.articles.count
    assert_no_difference '@user_with_articles.articles.count' do
      post :create, article: valid_article_attributes
    end
    article_response = json_response[:data]
    assert_not_nil article_response
    assert_equal before_create_count+1, @user.reload.articles.count

    assert_response 201
  end

  test "create should return json errors on invalid attributes" do
    invalid_article_attributes = { content: " " }
    log_in_as @user
    assert_no_difference '@user.articles.count' do
      post :create, article: invalid_article_attributes
    end
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /can't be blank/, article_errors[:content].to_s
  end

  test "create should return valid json on valid attributes" do
    valid_article_attributes = { content: "Valid text content\n newline, <p>html tags</p>" }
    log_in_as @user
    assert_difference '@user.articles.count', 1 do
      post :create, article: valid_article_attributes
    end
    article_response = json_response[:data]
    assert_not_nil article_response

    assert_response 201
  end
end
