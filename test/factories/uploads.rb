FactoryGirl.define do
  factory :upload do
    chunk_id { SecureRandom.hex }
    total_size 10
    ext "mp3"
    association :subject, factory: :podcast
  end
end
