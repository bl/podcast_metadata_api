module PodcastApiClient
  module V1
    class ClientNotConfigured < Exception
    end

    def self.configure(host, &block)
      @api = Her::API.new

      # configure Her ORM api
      @api.setup url: "http://api.#{host}" do |c|
        # Request
        c.use FaradayMiddleware::EncodeJson
        # Response
        c.use Her::Middleware::JsonApiParser
        # Adapter
        c.use Faraday::Adapter::NetHttp

        # yield configuration to provided code block for additional configuration
        yield c if block_given?
      end

      # load all models (must be done after creating api)
      Dir["lib/podcast_api_client/models/*"].each do |model_file|
        require File.expand_path model_file
      end
    end

    def self.api
      # throw not configured exception on call to api prior to configuration
      throw ClientNotConfigured.new("PodcastApiClient") unless @api
      @api
    end
  end
end
