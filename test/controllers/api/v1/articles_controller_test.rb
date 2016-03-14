require 'test_helper'

class Api::V1::ArticlesControllerTest < ActionController::TestCase

  def setup
    # create additional data
    # create podcast to publish articles to
    podcast = FactoryGirl.create :podcast
    # create published articles associated to timestamps for the podcast above
    2.times do
      user = FactoryGirl.create :activated_user
      2.times do
        create_published_article podcast, user
      end
    end

    # user with articles
    @user_with_articles = FactoryGirl.create :activated_user
    @articles = @user_with_articles.articles
    2.times do
      create_published_article podcast, @user_with_articles
      # create unpublished article
      @articles.create (FactoryGirl.attributes_for :article)
    end

    # create non-published articles
    @user_with_unpublished_articles = FactoryGirl.create :user_with_unpublished_articles
    @unpublished_articles = @user_with_unpublished_articles.articles

    # user without articles
    @user = FactoryGirl.create :activated_user
  end

  # SHOW

  test "get should return json errors on invalid article id" do
    get :show, id: -1
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /article/, article_errors.first[:id].to_s
    assert_match /is invalid/, article_errors.first[:detail].to_s
    
    assert_response 422
  end

  test "get should return json errors on unowned unpublished article id" do
    log_in_as @user
    get :show, id: @unpublished_articles.first
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /article/, article_errors.first[:id].to_s
    assert_match /is invalid/, article_errors.first[:detail].to_s

    assert_response 422
  end

  test "get should return valid json on owned unpublished article id" do
    log_in_as @user_with_unpublished_articles
    get :show, id: @unpublished_articles.first
    article_response = json_response[:data]
    assert_not_nil article_response
    assert_equal  @unpublished_articles.first.id, article_response[:id].to_i

    assert_response 200
  end

  test "get should return valid json on published article id" do
    get :show, id: @articles.first
    article_response = json_response[:data]
    assert_not_nil article_response
    assert_equal  @articles.first.id, article_response[:id].to_i

    assert_response 200
  end

  # INDEX

  test "index should return json of published articles ordered by published_at" do
    get :index
    articles_response = json_response[:data]
    assert_not_nil articles_response
    assert_equal Article.where(published: true).count, articles_response.count
    # verify article is ordered by published_at date and is published
    prev_date = articles_response.first[:attributes][:published_at]
    articles_response[2..-1].each do |article|
      cur_date = article[:attributes][:published_at]
      assert article[:attributes][:published]
      assert cur_date <= prev_date
      prev_date = cur_date
    end

    assert_response 200
  end

  ## BEGIN /USER_ID/ARTICLES
  
  # INDEX

  test "index should return all un/published user articles on valid user_id and logged in user" do
    log_in_as @user_with_articles
    get :index, { user_id: @user_with_articles.id }
    articles = @user_with_articles.articles
    articles_response = json_response[:data]
    assert_not_nil articles_response
    assert_equal articles.count, articles_response.count

    articles_response.each do |response|
      assert articles.ids.include? response[:id].to_i
    end

    assert_response 200
  end

  test "index should return published on published flag user articles on valid user_id and logged in user" do
    log_in_as @user_with_articles
    get :index, { user_id: @user_with_articles.id, published: true }
    published_articles = @user_with_articles.articles.where(published: true)
    articles_response = json_response[:data]
    assert_not_nil articles_response
    assert_equal published_articles.count, articles_response.count

    articles_response.each do |response|
      assert published_articles.ids.include? response[:id].to_i
    end

    assert_response 200
  end

  test "index should return published user articles on valid user_id and logged in non-owner" do
    log_in_as @user
    get :index, { user_id: @user_with_articles.id }
    published_articles = @user_with_articles.articles.where(published: true)
    articles_response = json_response[:data]
    assert_not_nil articles_response
    assert_equal published_articles.count, articles_response.count

    articles_response.each do |response|
      assert published_articles.ids.include? response[:id].to_i
    end

    assert_response 200
  end

  test "index should ignore published flag with user articles on valid user_id and logged in non-owner" do
    log_in_as @user
    get :index, { user_id: @user_with_articles.id, published: false }
    published_articles = @user_with_articles.articles.where(published: true)
    articles_response = json_response[:data]
    assert_not_nil articles_response
    assert_equal published_articles.count, articles_response.count

    articles_response.each do |response|
      assert published_articles.ids.include? response[:id].to_i
    end

    assert_response 200
  end

  test "index should return published user articles on valid user_id" do
    get :index, { user_id: @user_with_articles.id }
    published_articles = @user_with_articles.articles.where(published: true)
    articles_response = json_response[:data]
    assert_not_nil articles_response
    assert_equal published_articles.count, articles_response.count

    articles_response.each do |response|
      assert published_articles.ids.include? response[:id].to_i
    end

    assert_response 200
  end

  ## END /USER_ID/ARTICLES

  # CREATE

  test "create should return json errors when not logged in" do
    valid_article_attributes = { content: "Valid text content\n newline, <p>html tags</p>" }
    assert_no_difference '@user.articles.count' do
      post :create, article: valid_article_attributes
    end
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /user/, article_errors.first[:id].to_s
    assert_match /not authenticated/, article_errors.first[:detail].to_s

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
    assert_match /content/, article_errors.first[:id].to_s
    assert_match /can't be blank/, article_errors.first[:detail].to_s

    assert_response 422
  end

  test "create should return valid json on valid attributes" do
    valid_article_attributes = { content: "Valid text content\n newline, <p>html tags</p>" }
    log_in_as @user
    assert_difference '@user.articles.count', 1 do
      post :create, article: valid_article_attributes
    end
    article_response = json_response[:data]
    assert_not_nil article_response
    assert_equal @user.reload.articles.first.id, article_response[:id].to_i

    assert_response 201
  end

  ## BEGIN ARTICLE_ID/PUBLISH
  
  # CREATE
  test "publish create should return json errors when not logged-in" do
    #TODO: post :create
    assert_not true
  end

  test "create should return json errors when publish non-logged users article" do
    assert_not true
  end

  test "publish create should return valid json on valid article id" do
    assert_not true
  end

  # DESTROY
  
  test "publish destroy should return json errors when not logged-in" do
    assert_not true
  end

  test "destroy should return json errors when publish non-logged users article" do
    assert_not true
  end

  test "publish destroy should return empty payload on valid article id" do
    assert_not true
  end
  
  ## END ARTICLE_ID/PUBLISH
  
  # UPDATE

  test "update should return json errors when not logged-in" do
    valid_article_attributes = { content: "Valid text content\n newline, <p>html tags</p>" }
    patch :update, id: @articles.first, article: valid_article_attributes
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /user/, article_errors.first[:id].to_s
    assert_match /not authenticated/, article_errors.first[:detail].to_s

    assert_response :unauthorized
  end

  test "should return json errors when updating non-logged users article" do
    valid_article_attributes = { content: "Valid text content\n newline, <p>html tags</p>" }
    log_in_as @user
    patch :update, id: @articles.first, article: valid_article_attributes
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /article/, article_errors.first[:id].to_s
    assert_match /is invalid/, article_errors.first[:detail].to_s

    assert_response 422
  end

  test "update should return json errors when using invalid podcast id" do
    valid_article_attributes = { content: "Valid text content\n newline, <p>html tags</p>" }
    log_in_as @user_with_articles
    patch :update, id: -1, article: valid_article_attributes
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /article/, article_errors.first[:id].to_s
    assert_match /is invalid/, article_errors.first[:detail].to_s

    assert_response 422
  end

  test "update should return json errors on invalid attributes" do
    invalid_article_attributes = { content: " " }
    log_in_as @user_with_articles
    patch :update, id: @articles.first, article: invalid_article_attributes
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /content/, article_errors.first[:id].to_s
    assert_match /can't be blank/, article_errors.first[:detail].to_s

    assert_response 422
  end

  test "update should return valid json on valid attributes" do
    valid_article_attributes = { content: "Valid text content\n newline, <p>html tags</p>" }
    log_in_as @user_with_articles
    patch :update, id: @articles.first, article: valid_article_attributes
    article_response = json_response[:data]
    assert_not_nil article_response
    assert_equal valid_article_attributes[:content], @articles.first.reload.content 
    assert_equal valid_article_attributes[:content], article_response[:attributes][:content]

    assert_response 200
  end

  # DESTROY

  test "destroy should return authorization error when not logged in" do
    assert_no_difference '@articles.count' do
      delete :destroy, id: @articles.first
    end
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /user/, article_errors.first[:id].to_s
    assert_match /not authenticated/, article_errors.first[:detail].to_s

    assert_response :unauthorized
  end

  test "destroy should return json errors on invalid podcast id" do
    log_in_as @user_with_articles
    assert_no_difference '@articles.count' do
      delete :destroy, id: -1
    end
    article_errors = json_response[:errors]
    assert_match /article/, article_errors.first[:id].to_s
    assert_match /is invalid/, article_errors.first[:detail].to_s
    assert_not_nil article_errors

    assert_response 422
  end

  test "destroy should return json errors on deleting non-logged in users article" do
    log_in_as @user
    assert_no_difference '@articles.count' do
      delete :destroy, id: @articles.first
    end
    article_errors = json_response[:errors]
    assert_not_nil article_errors
    assert_match /article/, article_errors.first[:id].to_s
    assert_match /is invalid/, article_errors.first[:detail].to_s

    assert_response 422
  end

  test "destroy should return empty payload on valid article" do
    log_in_as @user_with_articles
    assert_difference '@articles.count', -1 do
      delete :destroy, id: @articles.first
    end
    assert_empty response.body

    assert_response 204
  end
end
