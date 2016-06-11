require 'test_helper'

class Api::V1::SeriesControllerTest < ActionController::TestCase
  include ResourcesControllerTest
  include PublishedControllerTest
  include PaginatedControllerTest
  include LimitedSearchControllerTest

  def setup
    # create additional data
    2.times do
      FactoryGirl.create :user_with_series
    end
    # user without series
    @user = FactoryGirl.create :activated_user

    # user with series
    @user_with_series = FactoryGirl.create :user_with_series
    @series = @user_with_series.series

    # create non-published series
    @user_with_unpublished_series = FactoryGirl.create :user_with_unpublished_series
    @unpublished_series = @user_with_unpublished_series.series
    include_default_accept_headers
  end

  def resource_class
    Series
  end

  def user
    @user
  end

  def user_with_resources
    @user_with_series
  end

  def user_with_unpublished_resources
    @user_with_unpublished_series
  end

  def all_published_resources
    Series.where published: true
  end

  def resources_for user
    user.series
  end

  def published_resources_for user
    user.published_series
  end

  def valid_resource_attributes
    valid_series_attributes = {
      title: "Hipster NYC Underground Jungle Boogie Break Beat Hits",
      description: "A podcast discussing the best in jungle boogie break beat"
    }
  end

  def invalid_resource_attributes
    invalid_series_attributes = {
      title: " ",
      description: "A podcast discussing the best in jungle boogie break beat"
    }
  end

  def invalid_attribute_id
    'title'
  end

  def invalid_attribute_detail
    "can't be blank"
  end

  # DELETE

  test "destroy should destroy all series dependent podcasts" do
    podcasts = @series.first.podcasts
    assert_difference 'Series.count', -1 do
      delete_as @user_with_series, :destroy, id: @series.first
    end

    assert_empty podcasts
    
    assert_response 204
  end

end
