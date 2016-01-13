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
    debugger

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
end
