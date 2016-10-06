require 'faraday'
require 'faraday_middleware'
require 'forwardable'

require 'beaker'

require 'beaker-http/helpers/puppet_helpers'
require 'beaker-http/dsl/web_helpers'
require "beaker-http/http"
require 'beaker-http/middleware/response/faraday_beaker_logger'
