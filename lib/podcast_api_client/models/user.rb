module PodcastApiClient
  module V1
    class User
      include Her::JsonApi::Model
      uses_api PodcastApiClient::V1.api
    end
  end
end
