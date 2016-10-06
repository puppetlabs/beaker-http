require 'spec_helper'

module Beaker
  module Http
    describe Connection do

      let(:options) {{ :logger => Beaker::Logger.new}}

      subject { Connection.new( options ) }

      context 'with a beaker logger in the options passed in ' do

        it 'does not raise errors' do
          expect {subject}.to_not raise_error
        end

        it 'sets a Faraday object as the instance connection object' do
          expect(subject.connection).to be_instance_of(Faraday::Connection)
        end

        it 'sets the middleware stack' do
          expect(subject.connection.builder.handlers).to eq(HttpHelpers::DEFAULT_MIDDLEWARE_STACK)
        end

        it 'routes all http verbs to the connection object' do
          http_verbs = [:get, :post, :put, :delete, :head, :patch]

          http_verbs.each do |verb|
            expect(subject.connection).to receive(verb)
            subject.send(verb)
          end
        end

        it 'routes other useful methods to the connection object' do
          useful_methods = [:url_prefix, :url_prefix=, :ssl]

          useful_methods.each do |method|
            expect(subject.connection).to receive(method)
            subject.send(method)
          end
        end

        describe '#remove_error_checking' do
          it 'removes the faraday middleware raising errors on 4xx and 5xx requests' do
            subject.remove_error_checking
            expect(subject.connection.builder.handlers).not_to include(Faraday::Response::RaiseError)
          end
        end

        context 'with a beaker host passed in' do
        unixhost = { roles:     ['test_role'],
                     'platform' => 'debian-7-x86_64' }
        let(:host) { Beaker::Host.create('test.com', unixhost, {}) }

          describe '#configure_cacert_with_puppet'
          it 'adds a ca_cert to the connection and changes the scheme to https' do
            allow(subject).to receive(:get_host_cacert).with(host).and_return('ca_file')
            subject.configure_cacert_with_puppet(host)
            expect(subject.connection.ssl['ca_file']).to eq('ca_file')
            expect(subject.connection.scheme).to eq('https')
          end

          describe '#configure_private_key_and_cert_with_puppet'
          it 'calls #configure_cacert_only_with_puppet and adds the host private key and cert' do
            allow(subject).to receive(:configure_cacert_with_puppet)
            allow(subject).to receive(:get_host_private_key).with(host).and_return('private_key')
            allow(subject).to receive(:get_host_cert).with(host).and_return('host_cert')

            allow(OpenSSL::PKey).to receive(:read).with('private_key').and_return('ssl_private_key')
            allow(OpenSSL::X509::Certificate).to receive(:new).with('host_cert').and_return('ssl_host_cert')

            subject.configure_private_key_and_cert_with_puppet(host)
            expect(subject.connection.ssl['client_key']).to eq('ssl_private_key')
            expect(subject.connection.ssl['client_cert']).to eq('ssl_host_cert')
          end
        end
      end
    end
  end
end
