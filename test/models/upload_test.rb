require 'test_helper'

class UploadTest < ActiveSupport::TestCase
  def setup
    @upload = FactoryGirl.build :upload
  end

  test "#subject should be present" do
    @upload.subject = nil
    refute @upload.valid?
  end

  test "#total_size must be present" do
    @upload.total_size = nil
    refute @upload.valid?
  end

  test "#total_size must be greater than 0" do
    @upload.total_size = -1
    refute @upload.valid?

    @upload.total_size = 0
    refute @upload.valid?

    @upload.total_size = 1
    assert @upload.valid?
  end

  test "#destroy cleans up any created file uploads" do
    assert false
  end

  test "#chunk_id should not change on multiple saves" do
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
end
