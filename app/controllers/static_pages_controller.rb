class StaticPagesController < ApplicationController
  def home
    record = PodcastApiClient::V1::User
    call = :all
    CallPodcastApiJob.perform_now record, call
  end

  def about
  end

  def help
  end

  def contact
  end
end
