require 'test_helper'

class UploadPodcastTest < ActionDispatch::IntegrationTest
  def setup
    host! 'api.lvh.me'

    @podcast = FactoryGirl.create :podcast
    @podcast.remove_podcast_file!
    @podcast.save

    @user = @podcast.series.user
  end

  test "upload successful on valid audio file" do
    podcast_file = open_podcast_file('piano-loop.mp3', 'audio/mp3')
    upload_params = {
      total_size: 1737212,
      ext: 'mp3'
    }
    chunk_params = {
      data: podcast_file
    }

    post api_podcast_uploads_path(@podcast), params: { upload: upload_params }, headers: headers_for(@user)
    assert_response :created
    upload = json_response

    patch api_upload_path(upload[:data][:id]), params: { upload: chunk_params }, headers: headers_for(@user)
    assert_response :ok
    upload = json_response

    #post upload_api_podcast_path(@podcast), upload: upload_params

    assert upload["data"]["attributes"]["finished?"]
    assert @podcast.reload.podcast_file.present?
    assert_equal podcast_file.size, @podcast.podcast_file.size
  end

  test "upload successful in multiple chunks" do
    podcast_file = open_podcast_file('piano-loop.mp3', 'audio/mp3')
    chunk_size = podcast_file.size / 5

    class Upload
      class << self
        def CHUNK_SIZE
          chunk_size
        end
      end
    end


    upload_progress = 0
    upload_in_chunks(podcast_file, chunk_size) do |chunk|
      upload_params = {
        total_size: podcast_file.size,
        data: chunk
      }

      post upload_api_podcast_path(@podcast), upload: upload_params

      upload = JSON.parse response.body
      upload_progress += chunk.size
      assert_equal upload_progress, upload["data"]["attributes"]["progress-size"]
    end

    upload = JSON.parse response.body
    assert upload["data"]["attributes"]["finished?"]

    get_as @user, api_podcast_path(@podcast)

    assert_equal podcast_file.size, assigns(:podcast).podcast_file.size
  end

  private

  def headers_for(user)
    { 'Authorization' => user.auth_token }
  end

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
