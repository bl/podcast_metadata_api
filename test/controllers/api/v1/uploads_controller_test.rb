require 'test_helper'

class Api::V1::UploadsControllerTest < ActionController::TestCase
  def setup
    @upload = FactoryGirl.create :stored_upload
    @user = @upload.subject.series.user
  end

  # SHOW

  test "#show should return json errors on invalid upload id" do
    get_as @user, :show, id: -1
    validate_response json_response[:errors], /upload/, /is invalid/
    
    assert_response 422
  end

  test "#show should return valid json upload on id param" do
  end
end
