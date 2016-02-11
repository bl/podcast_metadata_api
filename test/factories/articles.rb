FactoryGirl.define do
  factory :article do
    content { FFaker::Lorem::paragraph }
    association :author, factory: :user
  end
end
