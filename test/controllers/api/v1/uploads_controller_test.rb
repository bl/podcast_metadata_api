require 'test_helper'

class Api::V1::UploadsControllerTest < ActionController::TestCase
  def setup
    @upload = FactoryGirl.create :stored_upload
    @subject = @upload.subject
    @user = @subject.series.user

    @other_upload = FactoryGirl.create :stored_upload
    @other_subject = @other_upload.subject
    @other_user = @other_subject.series.user
  end

  # SHOW

  test "#show should return json errors on invalid upload id" do
    get_as @user, :show, id: -1
    validate_response json_response[:errors], /upload/, /is invalid/

    assert_response :unprocessable_entity
  end

  test "#show should return valid json upload on id param" do
    get_as @user, :show, id: @upload
    upload_response = json_response[:data]
    assert_not_nil upload_response
    assert_equal @upload.id, upload_response[:id].to_i

    assert_response :ok
  end

  # CREATE

  test "create should return json errors when not logged in" do
    assert_no_difference 'Upload.count' do
      post :create, podcast_id: @subject, upload: valid_post_params
    end
    validate_response json_response[:errors], /user/, /not authenticated/

    assert_response :unauthorized
  end

  test "create should only add upload to associated subjects uploads" do
    before_create_count = @subject.uploads.count
    assert_no_difference '@other_subject.uploads.count' do
      post_as @user, :create, podcast_id: @subject, upload: valid_post_params
    end
    upload_response = json_response[:data]
    assert_not_nil upload_response
    assert_equal before_create_count+1, @subject.uploads.reload.count

    assert_response :created
  end

  test "#create should return json errors when subjects user is not current user" do
    assert_no_difference '@subject.uploads.count' do
      post_as @other_user, :create, podcast_id: @subject, upload: valid_post_params
    end
    validate_response json_response[:errors], /podcast/, /is invalid/
  end

  test "create should return json errors on invalid attributes" do
    assert_no_difference '@subject.uploads.count' do
      post_as @user, :create, podcast_id: @subject, upload: invalid_post_params
    end
    validate_response json_response[:errors], /total_size/, /must be greater than 0/

    assert_response :unprocessable_entity
  end

  test "create should return valid json on valid attributes" do
    assert_difference '@subject.uploads.count', 1 do
      post_as @user, :create, podcast_id: @subject, upload: valid_post_params
    end
    upload_response = json_response[:data]
    assert_not_nil upload_response
    new_upload_id = @subject.uploads.reload.last.id
    assert_equal new_upload_id, upload_response[:id].to_i

    assert_response :created
  end

  private

  def valid_post_params
    {
      total_size: 1737212,
      ext: 'mp3'
    }
  end

  def invalid_post_params
    {
      total_size: -5,
      ext: ' '
    }
  end
end