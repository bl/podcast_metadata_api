FactoryGirl.define do
  factory :timestamp do
    transient do
      podcast_end_time 300
    end

    start_time  { rand(podcast_end_time-1) }
    end_time    { rand(podcast_end_time-1-start_time)+start_time+1 }
    podcast
  end
end
