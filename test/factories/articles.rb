FactoryGirl.define do
  factory :article do
    content { FFaker::Lorem::paragraphs }
    author nil
    timestamp nil
  end

end
