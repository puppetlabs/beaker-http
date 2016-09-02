require 'beaker-http'

module HttpHelpers
  DEFAULT_MIDDLEWARE_STACK = [FaradayMiddleware::EncodeJson,
                              FaradayMiddleware::FollowRedirects,
                              Faraday::Response::RaiseError,
                              FaradayMiddleware::ParseJson,
                              Beaker::Http::FaradayBeakerLogger,
                              Faraday::Adapter::NetHttp]
end
