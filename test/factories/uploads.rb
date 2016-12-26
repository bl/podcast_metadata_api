FactoryGirl.define do
  factory :upload do
    transient do
      upload_file_name "piano-loop.mp3"
    end

    association :subject, factory: :podcast
    user { subject.series.user }

    trait :file_present do
      before(:create) do |upload, evaluator|
        upload_file = fixture_file_upload("test/fixtures/podcasts/#{evaluator.upload_file_name}", "audio/mpeg")
        ChunkedUpload.new(upload).store_chunk(
          data: upload_file,
          total_size: upload_file.size
        )
      end
    end

    factory :stored_upload, traits: [:file_present]
  end
end
