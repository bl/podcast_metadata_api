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

    user.create_auth_token
    user.save
    user.auth_token
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

  def create_article_timestamp(podcast, article)
    # create timestamp attributes associated with article above
    timestamp_attributes = (FactoryGirl.attributes_for :timestamp, podcast_end_time: podcast.end_time).merge article_id: article.id
    timestamp = podcast.timestamps.create(timestamp_attributes)

    timestamp
  end

  # create published article on article_user to podcast
  def create_published_article(podcast, article_user)
    article = article_user.articles.create(FactoryGirl.attributes_for :article)
    create_article_timestamp(podcast, article)
    # publish article
    #article.update published: true, published_at: Time.zone.now
    ResourcePublisher.new(article).publish

    article
  end

  # send a post authenticated as the provided user
  # refer to send_as for documentation
  def post_as user, post_path, post_args = nil
    #post post_path, post_args, headers
    send_as :post, user, post_path, post_args
  end

  # send a delete authenticated as the provided user
  # refer to send_as for documentation
  def delete_as user, delete_path, delete_args = nil
    #delete delete_path, delete_args, headers
    send_as :delete, user, delete_path, delete_args
  end

  private

  # send a request of request type as the given user
  # user:     user to authenticate the delete as
  # req_type: type of request to send
  # req_path: path to req to
  # req_args: arguments for the req
  def send_as req_type, user, req_path, req_args = nil
    headers = { 'Authorization' => user.auth_token }
    self.send req_type, req_path, req_args, headers
  end

  def integration_test?
    defined? post_via_redirect
  end
end
