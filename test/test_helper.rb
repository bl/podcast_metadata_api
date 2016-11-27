ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #fixtures :all

  # mixin fixture_file_upload for podcast tests
  include ActionDispatch::TestProcess

  # mixin background job tests for ActionMailer email deliver_later's
  include ActiveJob::TestHelper

  def open_podcast_file(file_name, content_type = 'audio/')
   fixture_file_upload("podcasts/#{file_name}", content_type)
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

  # verify match of error type within a resource's response
  def validate_response resource_errors, attribute_id, attribute_detail
    assert_not_nil resource_errors
    assert_match attribute_id, resource_errors.first[:id].to_s
    assert_match attribute_detail, resource_errors.first[:detail].to_s
  end

  # send a patch authenticated as the provided user
  # refer to send_as for documentation
  def patch_as user, patch_path, patch_args = nil
    send_as :patch, user, patch_path, patch_args
  end

  # send a get authenticated as the provided user
  # refer to send_as for documentation
  def get_as user, get_path, get_args = nil
    send_as :get, user, get_path, get_args
  end

  # send a post authenticated as the provided user
  # refer to send_as for documentation
  def post_as user, post_path, post_args = nil
    send_as :post, user, post_path, post_args
  end

  # send a delete authenticated as the provided user
  # refer to send_as for documentation
  def delete_as user, delete_path, delete_args = nil
    send_as :delete, user, delete_path, delete_args
  end

  private

  # send a request of request type as the given user
  # user:     user to authenticate the delete as
  # req_type: type of request to send
  # req_path: path to req to (:get/:post, etc for non-integration version)
  # req_args: arguments for the req
  def send_as req_type, user, req_path, req_args = nil
    if integration_test?
      headers = { 'Authorization' => user.auth_token }
      self.send req_type, req_path, req_args, headers
    else #TODO: test non integration functionality
      request.headers['Authorization'] = user.auth_token
      self.send req_type, req_path, req_args
    end
  end

  def integration_test?
    defined? post_via_redirect
  end
end
