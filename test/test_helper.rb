ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

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
end
