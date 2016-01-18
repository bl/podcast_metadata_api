require 'test_helper'

class CallPodcastApiJobTest < ActiveJob::TestCase

  test "should return Podcast API response" do
    record = PodcastApiClient::V1::User
    call = :all
    perform_enqueued_jobs do
      CallPodcastApiJob.perform_now record, call
    end
  end
end
