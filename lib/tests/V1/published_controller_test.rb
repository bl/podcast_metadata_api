module PublishedControllerTest
  extend ActiveSupport::Testing::Declarative
  include ActionView::Helpers::TextHelper
  include ResourceTestHelper

  # SHOW

  test "get should return json errors on unowned unpublished resource id" do
    get_as user, :show, id: unpublished_resource
    validate_response json_response[:errors], resource_name, /is invalid/

    assert_response 422
  end

  test "get should return valid json on owned unpublished resource id" do
    get_as user_with_unpublished_resources, :show, id: unpublished_resource
    resource_response = json_response[:data]
    assert_not_nil resource_response
    assert_equal  unpublished_resource.id, resource_response[:id].to_i

    assert_response 200
  end

  test "get should return valid json on published resource id" do
    get :show, id: resource
    resource_response = json_response[:data]
    assert_not_nil resource_response
    assert_equal  resource.id, resource_response[:id].to_i

    assert_response 200
  end

  # INDEX

  test "index should return json of published resource ordered by published_at" do
    get :index
    resources_response = json_response[:data]
    assert_not_nil resources_response
    assert_equal resource_class.where(published: true).count, resources_response.count
    # verify resource is ordered by published_at date and is published
    prev_date = resources_response.first[:attributes][:"published-at"]
    resources_response[2..-1].each do |resource|
      cur_date = resource[:attributes][:"published-at"]
      assert resource[:attributes][:published]
      assert cur_date <= prev_date
      prev_date = cur_date
    end

    assert_response 200
  end

  test "index should return all un/published user resources on valid owner id and logged in user" do
    get_as user_with_resources, :index, valid_index_params
    resources = resources_for user_with_resources
    resources_response = json_response[:data]
    assert_not_nil resources_response
    assert_equal resources.count, resources_response.count

    resources_response.each do |response|
      assert resources.ids.include? response[:id].to_i
    end

    assert_response 200
  end

  test "index should return published resources on published flag valid owner id and logged in user" do
    get_as user_with_resources, :index, valid_index_params.merge(published: true)
    published_resources = published_resources_for user_with_resources
    resources_response = json_response[:data]
    assert_not_nil resources_response
    assert_equal published_resources.count, resources_response.count

    resources_response.each do |response|
      assert published_resources.ids.include? response[:id].to_i
    end

    assert_response 200
  end

  test "index should return published user resources on valid owner id and logged in non-owner" do
    get_as user, :index, valid_index_params
    published_resources = published_resources_for user_with_resources
    resources_response = json_response[:data]
    assert_not_nil resources_response
    assert_equal published_resources.count, resources_response.count

    resources_response.each do |response|
      assert published_resources.ids.include? response[:id].to_i
    end

    assert_response 200
  end

  test "index should ignore published flag with user resources on valid owner id and logged in non-owner" do
    get_as user, :index, valid_index_params.merge(published: false)
    published_resources = published_resources_for user_with_resources
    resources_response = json_response[:data]
    assert_not_nil resources_response
    assert_equal published_resources.count, resources_response.count

    resources_response.each do |response|
      assert published_resources.ids.include? response[:id].to_i
    end

    assert_response 200
  end

  test "index should return published user resources on valid owner id" do
    get :index, valid_index_params
    published_resources = published_resources_for user_with_resources
    resources_response = json_response[:data]
    assert_not_nil resources_response
    assert_equal published_resources.count, resources_response.count

    resources_response.each do |response|
      assert published_resources.ids.include? response[:id].to_i
    end

    assert_response 200
  end

  # TODO: verify valid_before/valid_after works regardless of results order, ie
  # searching with another form of ordering

  test "should return resources published after time" do
    get :index, { published_after: resource.published_at }
    assert_response 200
    resources_response = json_response[:data]
    assert_not_predicate resources_response, :empty?
    # verify all resources are ordered on/after given time (using default published-by ordering)
    resources_response.each do |resource_res|
      binding.pry
      assert resource.published_at <= DateTime.parse(resource_res[:attributes][:"published-at"])
    end
  end

  test "should return resources published before time" do
    get :index, { published_before: resource.published_at }
    assert_response 200
    resources_response = json_response[:data]
    assert_not_nil resources_response
    # verify all resources are ordered on/after given time (using default published-by ordering)
    resources_response.each do |resource_res|
      assert resource.published_at >= Time.new(resource_res[:attributes][:"published-at"])
    end
  end

  # PUBLISH

  test "publish should return json errors when not authenticated" do
    resource_to_publish = unpublished_resource
    prepare_resource_publish resource_to_publish if defined? prepare_resource_publish
    published_resources = published_resources_for user_with_unpublished_resources
    assert_no_difference 'published_resources.count' do
      post :publish, id: resource_to_publish
    end
    validate_response json_response[:errors], /user/, /not authenticated/

    assert_response :unauthorized
  end

  test "should return json errors when publishing non-authenticated users resource" do
    resource_to_publish = unpublished_resource
    prepare_resource_publish resource_to_publish if defined? prepare_resource_publish
    published_resources = published_resources_for user_with_unpublished_resources
    assert_no_difference 'published_resources.count' do
      post_as user, :publish, id: resource_to_publish
    end
    validate_response json_response[:errors], resource_name, /is invalid/

    assert_response 422
  end

  test "should return json errors when publishing already published resource" do
    post_as user_with_resources, :publish, id: resource
    validate_response json_response[:errors], resource_name, /is already published/

    assert_response 422
  end

  test "publish should return valid json on valid resource id" do
    resource_to_publish = unpublished_resource
    prepare_resource_publish resource_to_publish if defined? prepare_resource_publish
    published_resources = published_resources_for user_with_unpublished_resources
    assert_difference 'published_resources.count', 1 do
      post_as user_with_unpublished_resources, :publish, id: resource_to_publish
    end
    resource_response = json_response[:data]
    assert_not_nil resource_response
    assert resource_to_publish.reload.published
    assert resource_response[:attributes][:published]

    assert_response 200
  end

  # UNPUBLISH
  
  test "unpublish should return json errors when not authenticated" do
    published_resources = published_resources_for user_with_resources
    assert_no_difference 'published_resources.count' do
      delete :unpublish, id: resource
    end
    validate_response json_response[:errors], /user/, /not authenticated/

    assert_response :unauthorized
  end

  test "should return json errors when unpublish non-authenticated users resource" do
    published_resources = published_resources_for user_with_resources
    assert_no_difference 'published_resources.count' do
      delete_as user, :unpublish, id: resource
    end
    validate_response json_response[:errors], resource_name, /is invalid/

    assert_response 422
  end

  test "should return json errors when unpublishing an unpublished resource" do
    delete_as user_with_unpublished_resources, :unpublish, id: unpublished_resource
    validate_response json_response[:errors], resource_name, /is already unpublished/

    assert_response 422
  end

  # NOTE: resource may change after unpublishing if using ie series.first
  # due to default ordering. using a local variable to avoid this
  test "unpublish should return valid json on valid resource id" do
    resource_to_unpublish = resource
    published_resources = published_resources_for user_with_resources
    assert_difference 'published_resources.count', -1 do
      delete_as user_with_resources, :unpublish, id: resource_to_unpublish
    end
    resource_response = json_response[:data]
    assert_not_nil resource_response
    assert_not resource_to_unpublish.reload.published
    assert_not resource_response[:attributes][:published]

    assert_response 200
  end
end
