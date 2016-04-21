module ResourceTestHelper
  # helper methods
  
  # TODO: possibly look into a better way to represent names
  # TODO: remove dupliation in all resource tests by refactoring to shared inheritance class
  def resource_name
    @name ||= resource_class.name.downcase
  end

  def pluralized_name
    @pluralized_name ||= pluralize(2, resource_name).split.last
  end

  # merge resources post params to normal post params if they exist
  def valid_post_params
    get_post_params valid_resource_attributes
  end

  def invalid_post_params
    get_post_params invalid_resource_attributes
  end

  def get_post_params attributes
    params = { resource_name => attributes }
    return post_params.merge params if defined? post_params

    params
  end

  def resource
    resources.first
  end

  def resources
    resources_for user_with_resources
  end

  def unpublished_resources
    resources_for user_with_unpublished_resources
  end

  def unpublished_resource
    unpublished_resources.first
  end

  def valid_index_params
    return index_params if defined? index_params
    { user_id: user_with_resources.id }
  end
end
