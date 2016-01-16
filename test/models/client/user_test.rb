require 'test_helper'

class Client::UserTest < ActiveSupport::TestCase
  def setup
#    stub_api_for(Client::User) do |stub|
#      stub.get("/users") { |env| [200, {}, [{ id: 1, name: "Tester Testing"}].to_json] }
#    end
  end

  test "should return all stored users" do
    #assert_equal 10, Client::User.all.count
  end

end
