require 'test_helper'

class UploadTest < ActiveSupport::TestCase
  def setup
    @upload = FactoryGirl.build :upload
  end

  test "#subject should be present" do
    @upload.subject = nil
    refute @upload.valid?
  end

  test "#user should be present" do
    @upload.user = nil
    refute @upload.valid?
  end

  test "#total_size must be present" do
    @upload.total_size = nil
    refute @upload.valid?
  end

  test "#total_size must be greater than 0" do
    @upload.total_size = -1
    @upload.validate
    assert_equal @upload.errors[:total_size].first, 'must be greater than 0'

    @upload.total_size = 0
    @upload.validate
    assert_equal @upload.errors[:total_size].first, 'must be greater than 0'

    @upload.total_size = 1
    @upload.validate
    assert_empty @upload.errors[:total_size]
  end

  test "#destroy cleans up any created file uploads" do
    store_upload
    assert @upload.chunk_id.present?
    assert @upload.chunk.present?
    file_dir = @upload.file_dir

    @upload.destroy
    refute File.file?(file_dir)
  end

  test "#chunk_id should not change on multiple saves" do
    store_upload
    chunk_id = @upload.chunk_id
    @upload.save
    assert_equal chunk_id, @upload.reload.chunk_id
  end

  test "#chunk_id is assigned on validation if not present" do
    @upload.chunk_id = nil
    @upload.save
    assert @upload.chunk_id
  end

  test "#chunk_size is assigned on validation if not present" do
    @upload.chunk_size = nil
    @upload.save
    assert_equal @upload.chunk_size, Upload.CHUNK_SIZE
  end

  private

  def store_upload
    @upload.save
    ChunkedUpload.new(@upload).store_chunk(
      fixture_file_upload("podcasts/piano-loop.mp3", "audio/mpeg")
    )
  end
end
