require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  def setup
    # user with series containing podcasts
    @user_with_series = FactoryGirl.create(:user_with_series, series_count: 3)
    @article = @user_with_series.articles.build( content: "<body><p>html wrapped text</p></body>" )
    @series_with_podcasts = @user_with_series.series.first
    3.times do
        podcast = @series_with_podcasts.podcasts.create (FactoryGirl.attributes_for :podcast)
        podcast.timestamps.create FactoryGirl.attributes_for(:timestamp, podcast_end_time: podcast.end_time).merge(article: @article)
    end
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
    @series_with_podcasts.podcasts.each do |podcast|
      podcast.timestamps.each {|timestamp| timestamp.update_attribute :article, nil}
    end
    assert_not @article.valid?
    assert_match /Article cannot be published without an associated timestamp/, @article.errors[:base].to_s
  end
end
