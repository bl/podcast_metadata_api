Her::API.setup url: "http://api.lvh.me:3000" do |c|
  # Request
  c.use FaradayMiddleware::EncodeJson

  # Response
  c.use Her::Middleware::JsonApiParser

  # Adapter
  c.use Faraday::Adapter::NetHttp
end
