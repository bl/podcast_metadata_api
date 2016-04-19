require 'test_helper'

class ResourcePublishingTest < ActionDispatch::IntegrationTest
  # test publish routes using article
  def setup
    host! 'api.lvh.me'

    # TODO: DRY up duplication with ActionController tests
    # create additional data
    # create podcast to publish articles to
    @podcast = FactoryGirl.create :podcast
    # create published articles associated to timestamps for the podcast above
    2.times do
      user = FactoryGirl.create :activated_user
      2.times do
        create_published_article @podcast, user
      end
    end

    # user with articles
    @user_with_articles = FactoryGirl.create :activated_user
    @articles = @user_with_articles.articles
    2.times do
      create_published_article @podcast, @user_with_articles
      # create unpublished article
      @articles.create (FactoryGirl.attributes_for :article)
    end

    # create non-published articles
    @user_with_unpublished_articles = FactoryGirl.create :user_with_unpublished_articles
    @unpublished_articles = @user_with_unpublished_articles.articles

    # user without articles
    @user = FactoryGirl.create :activated_user
  end

  # PUBLISH

  test "publish should return json errors when not authenticated" do
    article = @unpublished_articles.first
    create_article_timestamp(@podcast, article)
    assert_no_difference '@user_with_unpublished_articles.published_articles.count' do
      post publish_api_article_path(article)
    end
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /user/, article_errors.first[:id].to_s
    assert_match /not authenticated/, article_errors.first[:detail].to_s

    assert_response :unauthorized
  end

  test "should return json errors when publishing non-authenticated users article" do
    article = @unpublished_articles.first
    create_article_timestamp(@podcast, article)
    assert_no_difference '@user_with_unpublished_articles.published_articles.count' do
      post_as @user, publish_api_article_path(article)
    end
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /article/, article_errors.first[:id].to_s
    assert_match /is invalid/, article_errors.first[:detail].to_s

    assert_response 422
  end

  test "should return json errors when publishing already published article" do
    article = @articles.first
    post_as @user_with_articles, publish_api_article_path(article)
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /article/, article_errors.first[:id].to_s
    assert_match /is already published/, article_errors.first[:detail].to_s

    assert_response 422
  end

  test "should return json errors when publishing incomplete article" do
    article = @unpublished_articles.first
    assert_no_difference '@user_with_unpublished_articles.published_articles.count' do
      post_as @user_with_unpublished_articles, publish_api_article_path(article)
    end
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /base/, article_errors.first[:id].to_s
    assert_match /Article cannot be published without an associated timestamp/, article_errors.first[:detail].to_s

    assert_response 422
  end

  test "publish should return valid json on valid article id" do
    article = @unpublished_articles.first
    create_article_timestamp(@podcast, article)
    assert_difference '@user_with_unpublished_articles.published_articles.count', 1 do
      post_as @user_with_unpublished_articles, publish_api_article_path(article)
    end
    article_response = json_response[:data]
    assert_not_nil article_response
    assert article_response[:attributes][:published]

    assert_response 200
  end

  # UNPUBLISH
  
  test "unpublish should return json errors when not authenticated" do
    article = @articles.first
    assert_no_difference '@user_with_articles.published_articles.count' do
      delete unpublish_api_article_path(article)
    end
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /user/, article_errors.first[:id].to_s
    assert_match /not authenticated/, article_errors.first[:detail].to_s

    assert_response :unauthorized
  end

  test "should return json errors when unpublish non-authenticated users article" do
    #log_in_as @user
    article = @articles.first
    assert_no_difference '@user_with_articles.published_articles.count' do
      delete_as @user, unpublish_api_article_path(article)
    end
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /article/, article_errors.first[:id].to_s
    assert_match /is invalid/, article_errors.first[:detail].to_s

    assert_response 422
  end

  test "should return json errors when unpublishing an unpublished article" do
    article = @unpublished_articles.first
    delete_as @user_with_unpublished_articles, unpublish_api_article_path(article)
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /article/, article_errors.first[:id].to_s
    assert_match /is already unpublished/, article_errors.first[:detail].to_s

    assert_response 422
  end

  test "unpublish should return valid json on valid article id" do
    article = @articles.first
    assert_difference '@user_with_articles.published_articles.count', -1 do
      delete_as @user_with_articles, unpublish_api_article_path(article)
    end
    article_response = json_response[:data]
    assert_not_nil article_response
    assert_not article.reload.published
    assert_not article_response[:attributes][:published]

    assert_response 200
  end
end
