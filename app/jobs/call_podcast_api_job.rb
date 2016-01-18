class CallPodcastApiJob < ActiveJob::Base
  queue_as :default

  def perform(record, call)
    result = record.send(call)
  end
end
