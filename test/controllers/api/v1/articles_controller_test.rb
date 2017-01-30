require 'test_helper'

class Api::V1::ArticlesControllerTest < ActionController::TestCase
  include ResourcesControllerTest
  include PublishedControllerTest
  include PaginatedControllerTest
  include LimitedSearchControllerTest

  def setup
    # create additional data
    # create podcast to publish articles to
    @podcast = FactoryGirl.create :podcast
    # create published articles associated to timestamps for the podcast above
    2.times do
      user = FactoryGirl.create :activated_user
      published_time = Time.now.utc.change(usec: 0)
      2.times do
        create_published_article @podcast, user, published_at: published_time -= 5.minutes
      end
    end

    # user with articles
    @user_with_articles = FactoryGirl.create :activated_user
    @articles = @user_with_articles.articles
    published_time = Time.now.utc.change(usec: 0)
    2.times do
      # create published article owned by @user_with_articles on @podcast
      create_published_article @podcast, @user_with_articles, published_at: published_time
      # create unpublished article
      @articles.create (FactoryGirl.attributes_for :article, published_at: published_time)

      published_time -= 5.minutes
    end

    # create non-published articles
    @user_with_unpublished_articles = FactoryGirl.create :user_with_unpublished_articles
    @unpublished_articles = @user_with_unpublished_articles.articles

    # user without articles
    @user = FactoryGirl.create :activated_user
  end

  # interface methods for included resource tests

  def resource_class
    Article
  end

  def user
    @user
  end

  def user_with_resources
    @user_with_articles
  end

  def user_with_unpublished_resources
    @user_with_unpublished_articles
  end

  def resources_for user
    user.articles
  end

  def published_resources_for user
    user.published_articles
  end

  def all_published_resources
    Article.where published: true
  end

  def valid_resource_attributes
    { content: "Valid text content\n newline, <p>html tags</p>" }
  end

  def invalid_resource_attributes
    { content: " " }
  end

  def invalid_attribute_id
    'content'
  end

  def invalid_attribute_detail
    "can't be blank"
  end

  # callback to prepare resource for publishing
  def prepare_resource_publish article
    create_article_timestamp(@podcast, article)
  end

  # PUBLISH

  test "should return json errors when publishing incomplete article" do
    article = @unpublished_articles.first
    assert_no_difference '@user_with_unpublished_articles.published_articles.count' do
      post_as @user_with_unpublished_articles, :publish, params: { id: article }
    end
    validate_response json_response[:errors], /base/, /Article cannot be published without an associated timestamp/

    assert_response 422
  end
end
