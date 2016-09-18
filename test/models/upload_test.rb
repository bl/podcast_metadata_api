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
end
