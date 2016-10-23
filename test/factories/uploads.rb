FactoryGirl.define do
  factory :upload do
    transient do
      upload_file_name "piano-loop.mp3"
    end

    chunk_id { SecureRandom.hex }
    total_size 10
    ext "mp3"
    association :subject, factory: :podcast

    after(:create) do |upload, elevator|
      ChunkedUpload.new(upload).store_chunk(
        fixture_file_upload("test/fixtures/podcasts/#{upload_file_name}", "audio/mpeg")
      )
    end
  end
end
