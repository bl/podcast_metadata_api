require 'podcast_api_client'

# configure Podcast client API using host
PodcastApiClient::V1.configure("lvh.me:3000") do |c|
  # TODO: implement caching on client api calls using faraday-http-cache
  #c.use :http_cache, Rails.cache, logger: Rails.logger
end
