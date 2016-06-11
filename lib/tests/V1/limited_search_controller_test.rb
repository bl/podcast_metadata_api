module LimitedSearchControllerTest
  extend ActiveSupport::Testing::Declarative
  include ResourceTestHelper
  
  test "should return limit many results if limit less than total" do
    # verify invalid limit field skips limit option
    get :index, { limit: "invalid-limit" }
    assert_response 200
    resources_response = json_response[:data]
    assert_not_nil resources_response
    assert_equal all_published_resources.count, resources_response.count

    get :index, { limit: 4 }
    assert_response 200
    resources_response = json_response[:data]
    assert_not_nil resources_response
    assert_equal 4, resources_response.count
    # verify resource is ordered by published_at date and is published
    prev_date = resources_response.first[:attributes][:"published-at"]
    resources_response[2..-1].each do |resource|
      cur_date = resource[:attributes][:"published-at"]
      assert cur_date <= prev_date
      prev_date = cur_date
    end
  end
end
