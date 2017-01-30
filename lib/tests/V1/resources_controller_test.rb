# test cases for all general resources, these include:
#   article, timestamp, podcast, series, user
module ResourcesControllerTest
  extend ActiveSupport::Testing::Declarative
  include ActionView::Helpers::TextHelper
  include ResourceTestHelper

  # SHOW

  test "get should return json errors on invalid resource id" do
    get :show, params: { id: -1 }
    validate_response json_response[:errors], resource_name, /is invalid/
    
    assert_response 422
  end

  # CREATE

  # TODO: separate user tests from all othe resource tests (below shouldn't be a user test)
  test "create should return json errors when not logged in" do
    user_resources = resources_for user
    assert_no_difference 'user_resources.count' do
      post :create, params: valid_post_params
    end
    validate_response json_response[:errors], /user/, /not authenticated/

    assert_response :unauthorized
  end

  test "create should only add resource to logged in users resources" do
    before_create_count = resources_for(user).count
    assert_no_difference 'resources.count' do
      post_as user, :create, params: valid_post_params
    end
    resource_response = json_response[:data]
    assert_not_nil resource_response
    assert_equal before_create_count+1, resources_for(user).reload.count

    assert_response 201
  end

  test "create should return json errors on invalid attributes" do
    user_resources = resources_for user
    assert_no_difference 'user_resources.count' do
      post_as user, :create, params: invalid_post_params
    end
    validate_response json_response[:errors], invalid_attribute_id, invalid_attribute_detail

    assert_response 422
  end

  test "create should return valid json on valid attributes" do
    user_resources = resources_for user
    assert_difference 'user_resources.count', 1 do
      post_as user, :create, params: valid_post_params
    end
    resource_response = json_response[:data]
    assert_not_nil resource_response
    new_resource_id = resources_for(user).reload.first.id
    assert_equal new_resource_id, resource_response[:id].to_i

    assert_response 201
  end

  # UPDATE

  test "update should return json errors when not logged-in" do
    patch :update, params: { id: resource, resource_name => valid_resource_attributes }
    validate_response json_response[:errors], /user/, /not authenticated/

    assert_response :unauthorized
  end

  test "should return json errors when updating non-logged users resource" do
    patch_as user, :update, params: { id: resource, resource_name => valid_resource_attributes }
    validate_response json_response[:errors], resource_name, /is invalid/

    assert_response 422
  end

  test "update should return json errors when using invalid resource id" do
    patch_as user_with_resources, :update, params: { id: -1, resource_name => valid_resource_attributes }
    validate_response json_response[:errors], resource_name, /is invalid/

    assert_response 422
  end

  test "update should return json errors on invalid attributes" do
    patch_as user_with_resources, :update, params: { id: resource, resource_name => invalid_resource_attributes }
    validate_response json_response[:errors], invalid_attribute_id, invalid_attribute_detail

    assert_response 422
  end

  test "update should return valid json on valid attributes" do
    invalid_sym = invalid_attribute_id.to_sym

    patch_as user_with_resources, :update, params: { id: resource, resource_name => valid_resource_attributes }
    resource_response = json_response[:data]
    assert_not_nil resource_response
    assert_equal valid_resource_attributes[invalid_sym], resource.reload.send(invalid_attribute_id)
    assert_equal valid_resource_attributes[invalid_sym], resource_response[:attributes][invalid_sym]

    assert_response 200
  end

  # DELETE

  test "destroy should return authorization error when not logged in" do
    assert_no_difference 'resources.count' do
      delete :destroy, params: { id: resource }
    end
    validate_response json_response[:errors], /user/, /not authenticated/

    assert_response :unauthorized
  end

  test "destroy should return json errors on invalid resource id" do
    assert_no_difference 'resources.count' do
      delete_as user_with_resources, :destroy, params: { id: -1 }
    end
    validate_response json_response[:errors], resource_name, /is invalid/

    assert_response 422
  end

  test "destroy should return json errors on deleting non-logged in users resource" do
    assert_no_difference 'resources.count' do
      delete_as user, :destroy, params: { id: resource }
    end
    validate_response json_response[:errors], resource_name, /is invalid/

    assert_response 422
  end

  test "destroy should return empty payload on valid resource" do
    assert_difference 'resources.count', -1 do
      delete_as user_with_resources, :destroy, params: { id: resource }
    end
    assert_empty response.body

    assert_response 204
  end
end
