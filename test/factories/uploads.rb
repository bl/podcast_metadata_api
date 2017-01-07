FactoryGirl.define do
  factory :upload do
    transient do
      completed_file { fixture_file_upload("test/fixtures/podcasts/piano-loop.mp3", "audio/mpeg") }
      partial_file { fixture_file_upload("test/fixtures/podcasts/piano-loop-chunk", "audio/mpeg") }
    end

    association :subject, factory: :podcast
    user { subject.series.user }
    total_size { completed_file.size }
    ext "mp3"

    before(:create) do |upload, evaluator|
      upload.chunk_size = evaluator.partial_file.size
    end

    trait :partial_file_present do
      after(:create) do |upload, evaluator|
        ChunkedUpload.new(upload).store_chunk(evaluator.partial_file)
      end
    end

    trait :file_present do
      after(:create) do |upload, evaluator|
        ChunkedUpload.new(upload).store_chunk(evaluator.completed_file)
      end
    end

    factory :empty_upload, traits: [:file_not_present]
    factory :partial_upload, traits: [:partial_file_present]
    factory :stored_upload, traits: [:file_present]
  end
end
