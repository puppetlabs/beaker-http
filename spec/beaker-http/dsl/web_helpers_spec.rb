require 'spec_helper'

class ClassMixedWithDSLWebHelpers
  include Beaker::DSL::Helpers

  attr_accessor :options

  def initialize
    @options = { logger: Beaker::Logger.new }
  end
end

describe ClassMixedWithDSLWebHelpers do

  describe '#generate_new_http_connection' do

    it 'raises an argument error if a non Beaker::Host is supplied' do
      expect{subject.generate_new_http_connection(Object.new)}.to raise_error(ArgumentError)
    end

    it 'raises no errors when no argument is supplied' do
      expect{subject.generate_new_http_connection}.to_not raise_error
    end

    context 'when passed a beaker host' do
      unixhost = { roles:     ['test_role'],
                   'platform' => 'debian-7-x86_64' }
      let(:host) { Beaker::Host.create('test.com', unixhost, {}) }
      let(:mock_options) { {:logger => Beaker::Logger.new} }
      let(:mock_connection) {double('connection')}

      it 'configures the connection object' do
        expect(mock_connection).to receive(:configure_private_key_and_cert_with_puppet).with(host)
        expect(Beaker::Http::Connection).to receive(:new).with(mock_options).and_return(mock_connection)
        allow(host).to receive(:options).and_return(mock_options)
        expect{subject.generate_new_http_connection(host)}.to_not raise_error
      end
    end

  end

  describe '#http_request' do
    let (:url) {"http://wwww.test.com"}
    let (:request_method) { :get }
    let (:mock_response) {double('reponse')}
    let (:mock_connection) { subject.generate_new_http_connection }
    let (:read_timeout) {double('read_timeout')}

    it 'sends a GET request to the url with the minimum required params' do
      expect(mock_connection).to receive(:get).and_return(mock_response)
      expect(URI).to receive(:parse).with(url).and_call_original
      expect(mock_connection).to receive(:url_prefix=).and_call_original
      expect(subject).to receive(:generate_new_http_connection).and_return(mock_connection)
      expect(subject.http_request(url, request_method)).to eq(mock_response)
    end

    context 'send a DELETE request to the url with the minimum required params' do
      let (:request_method) { :delete }
      it 'sends a DELETE request to the url with the minimum required params' do
        expect(mock_connection).to receive(:delete).and_return(mock_response)
        expect(URI).to receive(:parse).with(url).and_call_original
        expect(mock_connection).to receive(:url_prefix=).and_call_original
        expect(subject).to receive(:generate_new_http_connection).and_return(mock_connection)
        expect(subject.http_request(url, request_method)).to eq(mock_response)
      end
    end

    context 'when the request_method is POST' do
      let (:request_method) { :post }
      let (:body) {double('body')}
      let (:conn) { double('conn') }

      it 'sends a body along in the request' do
        expect(conn).to receive(:body=).with(body)
        expect(mock_connection).to receive(:post).and_yield(conn).and_return(mock_response)
        expect(URI).to receive(:parse).with(url).and_call_original
        expect(mock_connection).to receive(:url_prefix=).and_call_original
        expect(subject).to receive(:generate_new_http_connection).and_return(mock_connection)
        expect(subject.http_request(url, request_method, nil, nil, body, {})).to eq(mock_response)
      end
    end


    context 'when the request_method is PUT' do
      let (:request_method) { :put }
      let (:body) {double('body')}
      let (:conn) { double('conn') }

      it 'sends a body along in the request' do
        expect(conn).to receive(:body=).with(body)
        expect(mock_connection).to receive(:put).and_yield(conn).and_return(mock_response)
        expect(URI).to receive(:parse).with(url).and_call_original
        expect(mock_connection).to receive(:url_prefix=).and_call_original
        expect(subject).to receive(:generate_new_http_connection).and_return(mock_connection)
        expect(subject.http_request(url, request_method, nil, nil, body, {})).to eq(mock_response)
      end

    end

    it 'can set the timeout from the options hash passed in' do
      expect(mock_connection).to receive(:get).and_return(mock_response)
      expect(URI).to receive(:parse).with(url).and_call_original
      expect(mock_connection).to receive(:url_prefix=).and_call_original
      expect(subject).to receive(:generate_new_http_connection).and_return(mock_connection)
      expect(subject.http_request(url, request_method, nil, nil, nil, :read_timeout => read_timeout)).to eq(mock_response)
      expect(mock_connection.connection.options.timeout).to eq(read_timeout)
    end

    context 'with a key and cert provided' do
      let (:key) {'key'}
      let (:cert) {'cert'}
      it 'checks to ensure they are valid types and then adds them to the request' do

        expect(mock_connection).to receive(:get).and_return(mock_response)
        expect(key).to receive(:is_a?).with(OpenSSL::PKey::RSA).and_return(true)
        expect(cert).to receive(:is_a?).with(OpenSSL::X509::Certificate).and_return(true)
        expect(URI).to receive(:parse).with(url).and_call_original
        expect(mock_connection).to receive(:url_prefix=).and_call_original

        expect(subject).to receive(:generate_new_http_connection).and_return(mock_connection)

        expect(subject.http_request(url, request_method, cert, key)).to eq(mock_response)
        expect(mock_connection.ssl['client_key']).to eq(key)
        expect(mock_connection.ssl['client_cert']).to eq(cert)
      end

      it 'errors when an invalid key is provided' do
        expect(mock_connection).to_not receive(:get)
        expect(key).to receive(:is_a?).with(OpenSSL::PKey::RSA).and_call_original
        expect(cert).to receive(:is_a?).with(OpenSSL::X509::Certificate).and_return(true)
        expect(URI).to receive(:parse).with(url).and_call_original
        expect(mock_connection).to receive(:url_prefix=).and_call_original
        expect(subject).to receive(:generate_new_http_connection).and_return(mock_connection)
        expect{subject.http_request(url, request_method, cert, key)}.to raise_error(TypeError)
      end

      it 'errors when an invalid cert is provided' do
        expect(mock_connection).to_not receive(:get)
        expect(key).to_not receive(:is_a?).with(OpenSSL::PKey::RSA)
        expect(cert).to receive(:is_a?).with(OpenSSL::X509::Certificate).and_call_original
        expect(URI).to receive(:parse).with(url).and_call_original
        expect(mock_connection).to receive(:url_prefix=).and_call_original
        expect(subject).to receive(:generate_new_http_connection).and_return(mock_connection)
        expect{subject.http_request(url, request_method, cert, key)}.to raise_error(TypeError)
      end

    end

  end

end
