require 'test_helper'

class Api::V1::UploadsControllerTest < ActionController::TestCase
  def setup
    @upload = FactoryGirl.create :stored_upload
    @subject = @upload.subject
    @user = @subject.series.user

    @other_upload = FactoryGirl.create :stored_upload
    @other_subject = @other_upload.subject
    @other_user = @other_subject.series.user

    @empty_upload = FactoryGirl.create :upload
    @empty_subject = @empty_upload.subject
    @empty_user = @empty_subject.series.user

    @partial_upload = FactoryGirl.create :partial_upload
    @partial_subject = @partial_upload.subject
    @partial_user = @partial_subject.series.user
  end

  def teardown
    [@upload, @other_upload, @empty_upload, @partial_upload].each do |upload|
      ChunkedUpload.new(upload).cleanup if Upload.exists?(upload.id)
    end
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

  # UPDATE

  test "update should return json errors when not logged-in" do
    patch :update, id: @upload, upload: valid_post_params
    validate_response json_response[:errors], /user/, /not authenticated/

    assert_response :unauthorized
  end

  test "should return json errors when updating non-logged users resource" do
    patch_as @other_user, :update, id: @upload, upload: valid_post_params
    validate_response json_response[:errors], /upload/, /is invalid/

    assert_response :unprocessable_entity
  end

  test "update should return json errors when using invalid resource id" do
    patch_as @user, :update, id: -1, upload: valid_post_params
    validate_response json_response[:errors], /upload/, /is invalid/

    assert_response :unprocessable_entity
  end

  test "#update should return json errors when provided chunk size is incorrect" do
    @partial_upload.update(chunk_size: 10)

    patch_as @partial_user, :update, id: @partial_upload, upload: valid_chunk_params
    validate_response json_response[:errors], /chunk/, /is incorrect size. Use provided upload chunk size/

    assert_response :unprocessable_entity
  end

  test "#update should return json errors when upload is already finished" do
    patch_as @user, :update, id: @upload, upload: valid_chunk_params
    validate_response json_response[:errors], /upload/, /has already been completed/

    assert_response :unprocessable_entity
  end

  test "#update should return json errors when chunk is not present" do
    patch_as @empty_user, :update, id: @empty_upload, upload: { data: '' }
    validate_response json_response[:errors], /chunk/, /is not present/

    assert_response :unprocessable_entity
  end

  test "#update should return valid json after successful chunk upload" do
    patch_as @empty_user, :update, id: @empty_upload, upload: valid_chunk_params

    upload_response = json_response[:data]
    assert_not_nil upload_response
    assert_equal valid_chunk_params[:data].size, upload_response[:attributes][:'progress-size']
  end

  test "#update should update associated resource when upload is complete" do
    @empty_upload.subject.remove_podcast_file!
    @empty_upload.update(chunk_size: valid_completed_chunk_params[:data].size)

    patch_as @empty_user, :update, id: @empty_upload, upload: valid_completed_chunk_params

    upload_response = json_response[:data]
    assert_not_nil upload_response
    assert upload_response[:attributes][:finished?]
    assert_predicate @empty_upload.subject.reload.podcast_file, :present?
  end

  # DELETE

  test "destroy should return authorization error when not logged in" do
    assert_no_difference 'Upload.count' do
      delete :destroy, id: @upload
    end
    validate_response json_response[:errors], /user/, /not authenticated/

    assert_response :unauthorized
  end

  test "destroy should return json errors on invalid upload id" do
    assert_no_difference 'Upload.count' do
      delete_as @user, :destroy, id: -1
    end
    validate_response json_response[:errors], /upload/, /is invalid/

    assert_response 422
  end

  test "destroy should return json errors on deleting non-logged in users upload" do
    assert_no_difference 'Upload.count' do
      delete_as @other_user, :destroy, id: @upload
    end
    validate_response json_response[:errors], /upload/, /is invalid/

    assert_response 422
  end

  test "destroy should return empty payload on valid upload" do
    upload_file_dir = @upload.file_dir
    assert_difference 'Upload.count', -1 do
      delete_as @user, :destroy, id: @upload
    end
    assert_empty response.body
    refute File.exist?(upload_file_dir)

    assert_response 204
  end

  private

  def valid_post_params
    {
      total_size: 1737212,
      ext: 'mp3'
    }
  end

  def valid_chunk_params
    @valid_chunk_params ||= {
      data: fixture_file_upload("podcasts/piano-loop-chunk", "audio/mpeg")
    }
  end

  def valid_completed_chunk_params
    @valid_completed_chunk_params ||= {
      data: fixture_file_upload("podcasts/piano-loop.mp3", "audio/mpeg")
    }
  end

  def invalid_post_params
    {
      total_size: -5,
      ext: ' '
    }
  end
end
