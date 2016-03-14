FactoryGirl.define do
  factory :article do
    content { FFaker::Lorem::paragraph }
    association :author, factory: :user

    trait :published do
      published true
      published_at { Time.zone.now }
    end

    factory :published_article, traits: [:published]
  end
end
