module Beaker::DSL::Helpers::WebHelpers

  def generate_new_http_connection(host=nil)
    connection = Beaker::Http::Connection.new(options)

    if host
      connection.configure_private_key_and_cert_with_puppet(host)
    end

    connection
  end

  def https_request(url, request_method, cert=nil, key=nil, body=nil, options={})
    connection = generate_new_http_connection

    connection.url_prefix = URI.parse(url)

    if cert
      if cert.is_a?(OpenSSL::X509::Certificate)
        connection.set_client_cert(cert)
      else
        raise TypeError, "cert must be an OpenSSL::X509::Certificate object, not #{cert.class}"
      end
    end

    if key
      if key.is_a?(OpenSSL::PKey::RSA)
        connection.set_client_key(key)
      else
        raise TypeError, "key must be an OpenSSL::PKey:RSA object, not #{key.class}"
      end
    end

    # ewwww
    connection.connection.ssl[:verify] = false

    connection.options.timeout = options[:read_timeout] if options[:read_timeout]

    if request_method == :post
      response = connection.post { |conn| conn.body = body }
    else
      response = connection.get
    end
    response
  end
end
