FactoryGirl.define do
  factory :user do
    name  { FFaker::Name.name }
    email { FFaker::Internet.email }
    password              "password"
    password_confirmation "password"

    trait :activated do
      auth_token { User.new_token }
      activated true
      activated_at { Time.zone.now }
    end

    factory :activated_user, traits: [:activated]

    factory :user_with_series, parent: :activated_user do
      transient do
        series_count 3
      end

      after(:create) do |user, evaluator|
        create_list(:series, evaluator.series_count, user: user)
      end
    end

    factory :user_with_articles, parent: :activated_user do
      transient do
        articles_count 3
      end

      after(:create) do |user, evaluator|
        create_list(:article, evaluator.articles_count, author: user)
      end
    end
  end
end
