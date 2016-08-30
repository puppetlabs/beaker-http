module Beaker
  module Http
    module Helpers

      def get_host_cacert(host)
        cacert_on_host= host.puppet['localcacert']
        # puppet may not have laid down the cacert yet, so check to make sure
        # the file exists
        host.execute("test -f #{cacert_on_host}")
        ca_cert = host.execute("cat #{cacert_on_host}", :silent => true)
        cert_dir = Dir.mktmpdir("pe_certs")
        ca_cert_file = File.join(cert_dir, "cacert.pem")
        File.open(ca_cert_file, "w+") do |f|
          f.write(ca_cert)
        end
        ca_cert_file
      end

      def get_host_private_key(host)
        private_key = host.puppet['hostprivkey']
        # puppet may not have laid down the private_key yet, so check to make sure
        # the file exists
        host.execute("test -f #{private_key}")
        host.execute("cat #{private_key}", :silent => true)
      end

      def get_host_cert(host)
        hostcert = host.puppet['hostcert']
        # puppet may not have laid down the hostcert yet, so check to make sure
        # the file exists
        host.execute("test -f #{hostcert}")
        host.execute("cat #{hostcert}", :silent => true)
      end

    end
  end
end
