FactoryGirl.define do
  factory :user do
    name  { FFaker::Name.name }
    email { FFaker::Internet.email }
    password              "password"
    password_confirmation "password"

    factory :user_with_series do
      transient do
        series_count 3
      end

      after(:create) do |user, evaluator|
        create_list(:series, evaluator.series_count, user: user)
      end
    end

    factory :user_with_articles do
      transient do
        articles_count 3
      end

      after(:create) do |user, evaluator|
        create_list(:article, evaluator.articles_count, author: user)
      end
    end
  end
end
