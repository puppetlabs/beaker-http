require 'spec_helper'

describe Beaker::Http::FaradayBeakerLogger do

  let(:conn) { Faraday.new(:url => 'http://test.com/path') }
  let(:host) {
    unixhost = { roles:     ['test_role'],
                 'platform' => 'debian-7-x86_64' }
    host = Beaker::Host.create('deb7', unixhost, {})
    host.logger = Beaker::Logger.new
    host
  }


  context 'with log bodies turned off' do

    before do
      conn.builder.insert(0, Beaker::Http::FaradayBeakerLogger, host)
      conn.adapter :test do |stub|
        stub.get('/path') {[200, {}, 'success']}
      end
    end

    it 'sends info and debug requests to the logger' do
      expect(host.logger).to receive(:info).with('GET: http://test.com/path').once
      expect(host.logger).to receive(:info).with(/RESPONSE CODE: 200/).once
      expect(host.logger).to receive(:debug).with(/REQUEST HEADERS:/).once
      expect(host.logger).to receive(:debug).with(/RESPONSE HEADERS:/).once
      conn.get
    end
  end

  context 'with log bodies turned on' do

    before do
      conn.builder.insert(0, Beaker::Http::FaradayBeakerLogger, host, :bodies => true)
      conn.adapter :test do |stub|
        stub.post('/path') {[201, {}, 'success']}
      end
    end

    it 'sends extra debug requests to the logger' do
      expect(host.logger).to receive(:info).with('POST: http://test.com/path').once
      expect(host.logger).to receive(:info).with(/RESPONSE CODE: 201/).once
      expect(host.logger).to receive(:debug).with(/RESPONSE BODY:/).once
      expect(host.logger).to receive(:debug).with(/REQUEST BODY:/).once
      expect(host.logger).to receive(:debug).with(/REQUEST HEADERS:/).once
      expect(host.logger).to receive(:debug).with(/RESPONSE HEADERS:/).once
      conn.post() { |connection| connection.body = "BODY MOVIN'" }
    end
  end
end
