module PaginatedControllerTest
  extend ActiveSupport::Testing::Declarative
  include ResourceTestHelper

  #TODO: uncomment once implemented in all paginatable models
  test "should paginate resources in groups of limit and offset in recurring calls" do
    resources_response = []
    loop do
      params = { limit: 3 }
      params.merge! offset: resources_response.count if resources_response.count > 0

      get :index, params
      res = json_response[:data]
      assert_not_nil res

      resources_response += res
      break if res.count == 0
    end
    all_resources = all_published_resources
    assert_equal all_resources.count, resources_response.count
    # verify response result contains all ids
    response_resource_ids = resources_response.map {|x| x[:id].to_i }
    assert (response_resource_ids - all_resources.ids).empty?
  end
end
