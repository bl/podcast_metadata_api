require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    host! 'api.lvh.me'

    @user = FactoryGirl.create :activated_user
  end

  test "create request should return error with invalid user email" do
  end

  test "create request should return valid response on valid user email" do
  end
end
