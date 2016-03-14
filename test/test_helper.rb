ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  # mixin fixture_file_upload for podcast tests
  include ActionDispatch::TestProcess

  def open_podcast_file(file_name)
   fixture_file_upload("podcasts/#{file_name}", 'audio/') 
  end

  def api_authorization_header(token)
    request.headers['Authorization'] = token
  end

  def create_session_for(user, options = {})
    password = options[:password] || 'password'
    if integration_test?
      post api_sessions_path, session: { email:    user.email,
                                           password: password }
      json_response[:data][:attributes][:auth_token]
    else
      user.create_auth_token
      user.save
      user.auth_token
    end
  end

  # log in as user by creating session for user, then setting authorization header
  def log_in_as(user, options = {})
    api_authorization_header create_session_for(user, options)
  end

  # return json from response body
  def json_response
    JSON.parse response.body, symbolize_names: true
  end

  # add API version to request headers
  def api_header(version = 1)
    api_version = "application/vnd.podcast_metadata.v#{version}"
    request.headers['Accept'] = api_version
  end

  # add JSON mime type to request headers
  def api_response_format(format = Mime::JSON)
    request.headers['Accept'] = "#{request.headers['Accept']},#{format}"
    request.headers['Content-Type'] = format.to_s
  end

  # add both API version and JSON mime type to request headers
  def include_default_accept_headers
    api_header
    api_response_format
  end

  # create published article on article_user to podcast
  def create_published_article(podcast, article_user)
    article = article_user.articles.create(FactoryGirl.attributes_for :article)
    # create timestamp attributes associated with article above
    timestamp_attributes = (FactoryGirl.attributes_for :timestamp, podcast_end_time: podcast.end_time).merge article_id: article.id
    timestamp = podcast.timestamps.create(timestamp_attributes)
    # publish article
    article.update published: true, published_at: Time.zone.now

    article
  end

  private

    def integration_test?
      defined? post_via_redirect
    end
end
