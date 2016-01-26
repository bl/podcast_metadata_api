FactoryGirl.define do
  factory :series do
    title { FFaker::HipsterIpsum.words(5) }
    published false
    user
  end

  factory :series_with_podcasts do
    transient do
      podcasts_count 3
    end

    after(:create) do |series, evaluator|
      create_list(:podcast, evaluator_podcasts_count, series: series)
    end
  end

  #TODO: refactor series factories using options
#  factory :series_with_podcasts_timestamps do
#    transient do
#      podcasts_count 3
#    end
#
#    after(:create) do |series, evaluator|
#      create_list(:podcast, evaluator_podcasts_count, series: series)
#    end
#  end

end