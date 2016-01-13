FactoryGirl.define do
  factory :article do
    content { FFaker::Lorem::paragraphs }
    association :author, factory: :user
  end
end
