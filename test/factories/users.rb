FactoryGirl.define do
  factory :user do
    name  { FFaker::Name.name }
    email { FFaker::Internet.email }
    password              "password"
    password_confirmation "password"

    factory :user_with_podcasts do
      transient do
        podcasts_count 3
      end

      after(:create) do |user, evaluator|
        create_list(:podcast, evaluator.podcasts_count, user: user)
      end
    end
  end
end
