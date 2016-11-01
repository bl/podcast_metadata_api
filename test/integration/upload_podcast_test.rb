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
    assert upload["data"]["attributes"]["finished?"]
    assert @podcast.reload.podcast_file.present?
    assert_equal podcast_file.size, @podcast.podcast_file.size
  end

  test "upload successful in multiple chunks" do
    podcast_file = open_podcast_file('piano-loop.mp3')
    chunk_size = podcast_file.size / 5

    class Upload
      class << self
        def CHUNK_SIZE
          chunk_size
        end
      end
    end


    upload_in_chunks(podcast_file, chunk_size) do |chunk|
      upload_params = {
        total_size: podcast_file.size,
        data: chunk
      }

      post upload_api_podcast_path(@podcast), upload: upload_params
    end

    get status_api_podcast_path(@podcast)

    upload = JSON.parse response.body
    assert upload["data"]["attributes"]["finished?"]
  end

  private

  def upload_in_chunks(file, chunk_size)
    while chunk_data = file.read(chunk_size)
      chunk = Tempfile.new('chunk_name')
      begin
        chunk.binmode
        chunk.write(chunk_data)
        chunk.close

        yield Rack::Test::UploadedFile.new(chunk.path, 'audio/mp3')
      ensure
        chunk.close!
      end
    end
  end
end
