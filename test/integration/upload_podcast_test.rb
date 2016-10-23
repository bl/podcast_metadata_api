require 'test_helper'

class UploadPodcastTest < ActionDispatch::IntegrationTest
  def setup
    host! 'api.lvh.me'

    @podcast = FactoryGirl.create :podcast
    @podcast.remove_podcast_file!
    @podcast.save
  end

  test "upload successful on valid audio file" do
    podcast_file = open_podcast_file('piano-loop.mp3')
    upload_params = {
      total_size: podcast_file.size,
      data: podcast_file
    }

    post upload_api_podcast_path(@podcast), upload: upload_params

    upload = JSON.parse response.body
    assert @podcast.podcast_file.present?
  end

  #test "upload successful in multiple chunks" do

  #end
end
