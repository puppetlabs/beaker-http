module Beaker
  module Http

    # Beaker Http objects are essentially wrappers for a connection object that
    # utilizes a Beaker::Host object for easier setup during testing.
    class Connection
      include Beaker::Http::Helpers
      extend Forwardable

      attr_accessor :connection
      attr_reader :host

      def initialize(host)
        @host = host

        if @host.is_a?(Beaker::Host)
          @connection = create_default_connection
        else
          raise "Argument host must be Beaker::Host"
        end

        connection.url_prefix.host = host.hostname
      end

      def_delegators :@connection, :get, :post, :put, :delete, :head, :patch

      def create_default_connection
        Faraday.new do |conn|
          conn.request :json

          conn.response :follow_redirects
          conn.response :raise_error
          conn.response :json, :content_type => /\bjson$/
          conn.response :faraday_beaker_logger, @host, bodies: true

          conn.adapter :net_http
        end
      end

      # If you would like to run tests that expect 400 or even 500 responses,
      # apply this method to remove the <tt>:raise_error</tt> middleware.
      def remove_error_checking
        connection.builder.delete(Faraday::Response::RaiseError)
        nil
      end

      # Use this method if you are connecting as a user to the system; it will
      # provide the correct SSL context but not provide authentication.
      def configure_cacert_only_with_puppet
        connection.ssl['ca_file'] = get_host_cacert(@host)
        connection.scheme = 'https'
        nil
      end

      # Use this method if you want to connect to the system using certificate
      # based authentication.
      def configure_private_key_and_cert_with_puppet
        configure_cacert_only_with_puppet
        client_key = get_host_private_key(@host)
        client_cert = get_host_cert(@host)
        connection.ssl['client_key'] = OpenSSL::PKey.read(client_key)
        connection.ssl['client_cert'] = OpenSSL::X509::Certificate.new(client_cert)
        nil
      end

    end
  end
end
