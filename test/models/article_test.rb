require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  def setup
    @user_with_podcasts = FactoryGirl.create :user_with_podcasts
    @article = @user_with_podcasts.articles.build( content: "<body><p>html wrapped text</p></body>" )
  end

  test "should be valid" do
    assert @article.valid?
  end

  # author

  test "author should be present" do
    @article.author = nil
    assert_not @article.valid?
  end

  # content

  test "content should be present" do
    @article.content = "  "
    assert_not @article.valid?
  end

  # published

  test "should not be published when timestamp is not present" do
    @article.published = true
    assert_not @article.valid?
    assert_match /Article cannot be published without an associated timestamp/, @article.errors[:base].to_s
  end
end
