FactoryGirl.define do
  factory :series do
    title { FFaker::HipsterIpsum.words(3) }
    published false
    association :user, factory: :activated_user
  end

  factory :series_with_podcasts do
    transient do
      podcasts_count 3
    end

    after(:create) do |series, evaluator|
      create_list(:podcast, evaluator_podcasts_count, series: series)
    end
  end
end
