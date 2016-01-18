class StaticPagesController < ApplicationController
  def home
    @users = PodcastApiClient::V1::User.all
  end

  def about
  end

  def help
  end

  def contact
  end
end
