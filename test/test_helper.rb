ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  # mixin fixture_file_upload for podcast tests
  include ActionDispatch::TestProcess

  # TODO: move to test_helper exclusively for client
  # stub api for client resource model to use Her api tests
  def stub_api_for(model)
    PodcastApiClient::V1.configure "lvh.me:9292" do |c|
      c.use Her::Middleware::FirstLevelParseJSON
      c.adapter(:test) { |s| yield(s) }
    end

    model.use_api PodcastApiClient::V1.api
  end

  def open_podcast_file(file_name)
   fixture_file_upload("podcasts/#{file_name}", 'audio/') 
  end

  def api_authorization_header(token)
    request.headers['Authorization'] = token
  end

  def create_session_for(user, options = {})
    password = options[:password] || 'password'
    if integration_test?
      create sessions_path, session: { email:    user.email,
                                       password: password }
      json_response[:auth_token]
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

  private

    def integration_test?
      defined? post_via_redirect
    end
end
