FactoryGirl.define do
  factory :user do
    name  { FFaker::Name.name }
    email { FFaker::Internet.email }
    password              "password"
    password_confirmation "password"

    trait :activated do
      auth_token { User.new_token }
      activated true
      activated_at { Time.now.utc }
    end

    factory :activated_user, traits: [:activated]
  end

  factory :user_with_series, parent: :activated_user do
    transient do
      series_count 3
    end

    after(:create) do |user, evaluator|
      # truncate nanoseconds to 0
      published_time = Time.now.utc.change(usec: 0)
      evaluator.series_count.times do
        create :published_series, user: user, published_at: (published_time -= 5.minutes)
      end
    end
  end

  factory :user_with_unpublished_series, parent: :activated_user do
    transient do
      series_count 3
    end

    after(:create) do |user, evaluator|
      create_list(:series, evaluator.series_count, user: user)
    end
  end

  factory :user_with_published_podcasts, parent: :user_with_series do
    transient do
      podcasts_count 3
    end

    after(:create) do |user, evaluator|
      published_time = Time.now.utc.change(usec: 0)
      evaluator.podcasts_count.times do
        create :published_podcast, series: user.series.first, published_at: (published_time -= 5.minutes)
      end
    end
  end

  factory :user_with_unpublished_podcasts, parent: :user_with_series do
    transient do
      podcasts_count 3
    end

    after(:create) do |user, evaluator|
      create_list(:podcast, evaluator.podcasts_count, series: user.series.first)
      #published_time = Time.now.utc.change(usec: 0)
      #evaluator.podcasts_count.times do
        #create :podcast, series: user.series.first, published_at: (published_time -= 5.minutes)
      #end
    end
  end

  factory :user_with_unpublished_articles, parent: :activated_user do
    transient do
      articles_count 3
    end

    after(:create) do |user, evaluator|
      create_list(:article, evaluator.articles_count, author: user)
    end
  end
end
