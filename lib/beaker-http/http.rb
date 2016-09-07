module Beaker
  module Http

    # Beaker Http objects are essentially wrappers for a connection object that
    # utilizes a Beaker::Host object for easier setup during testing.
    class Connection
      include Beaker::Http::Helpers
      extend Forwardable

      attr_accessor :connection

      def initialize(options)
        @connection = create_default_connection(options)
      end

      def_delegators :connection, :get, :post, :put, :delete, :head, :patch, :scheme, :scheme=, :host, :host=, :port, :port=, :url_prefix, :url_prefix=

      def create_default_connection(options)
        Faraday.new do |conn|
          conn.request :json

          conn.response :follow_redirects
          conn.response :raise_error
          conn.response :json, :content_type => /\bjson$/
          conn.response :faraday_beaker_logger, options[:logger], bodies: true

          conn.adapter :net_http
        end
      end

      # If you would like to run tests that expect 400 or even 500 responses,
      # apply this method to remove the <tt>:raise_error</tt> middleware.
      def remove_error_checking
        connection.builder.delete(Faraday::Response::RaiseError)
        nil
      end

      def set_cacert(ca_file)
        connection.ssl['ca_file'] = ca_file
        connection.scheme = 'https'
      end

      def set_client_key(client_key)
        connection.ssl['client_key'] = client_key
      end

      def set_client_cert(client_cert)
        connection.ssl['client_cert'] = client_cert
      end

      # Use this method if you are connecting as a user to the system; it will
      # provide the correct SSL context but not provide authentication.
      def configure_cacert_with_puppet(host)
        set_cacert(get_host_cacert(host))
        connection.host = host.hostname
        nil
      end

      # Use this method if you want to connect to the system using certificate
      # based authentication. This method will provide the ssl context and use
      # the private key and cert from the host provided for authentication.
      def configure_private_key_and_cert_with_puppet(host)
        configure_cacert_with_puppet(host)

        client_key_raw = get_host_private_key(host)
        client_cert_raw = get_host_cert(host)

        set_client_key(OpenSSL::PKey.read(client_key_raw))
        set_client_cert(OpenSSL::X509::Certificate.new(client_cert_raw))

        nil
      end

    end
  end
end
