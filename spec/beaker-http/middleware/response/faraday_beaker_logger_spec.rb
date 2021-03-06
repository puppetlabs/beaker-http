require 'spec_helper'

describe Beaker::Http::FaradayBeakerLogger do

  let(:conn) { Faraday.new(:url => 'http://test.com/path') }
  let (:logger) { Beaker::Logger.new }

  context 'with log bodies turned off' do

    before do
      conn.builder.insert(0, Beaker::Http::FaradayBeakerLogger, logger, :bodies => false)
      conn.adapter :test do |stub|
        stub.get('/path') {[200, {}, 'success']}
      end
    end

    it 'sends info and debug requests to the logger' do
      expect(logger).to receive(:info).with('GET: http://test.com/path').once
      expect(logger).to receive(:info).with(/RESPONSE CODE: 200/).once
      expect(logger).to receive(:debug).with(/ELAPSED TIME:/).once
      expect(logger).to receive(:debug).with(/REQUEST HEADERS:/).once
      expect(logger).to receive(:debug).with(/RESPONSE HEADERS:/).once
      expect(logger).to_not receive(:debug).with(/RESPONSE BODY:/)
      expect(logger).to_not receive(:debug).with(/REQUEST BODY:/)
      conn.get
    end
  end

  context 'with log bodies turned on' do

    before do
      conn.builder.insert(0, Beaker::Http::FaradayBeakerLogger, logger, :bodies => true)
      conn.adapter :test do |stub|
        stub.post('/path') {[201, {}, 'success']}
      end
    end

    it 'sends extra debug requests to the logger' do
      expect(logger).to receive(:info).with('POST: http://test.com/path').once
      expect(logger).to receive(:info).with(/RESPONSE CODE: 201/).once
      expect(logger).to receive(:debug).with(/ELAPSED TIME:/).once
      expect(logger).to receive(:debug).with(/RESPONSE BODY:\nsuccess/).once
      expect(logger).to receive(:debug).with(/REQUEST BODY:\nBODY MOVIN'/).once
      expect(logger).to receive(:debug).with(/REQUEST HEADERS:/).once
      expect(logger).to receive(:debug).with(/RESPONSE HEADERS:/).once
      conn.post() { |connection| connection.body = "BODY MOVIN'" }
    end
  end

  context 'when body responses do not respond to :to_str' do
    let (:array_response) { [1, 2, 3] }
    before do
      conn.builder.insert(0, Beaker::Http::FaradayBeakerLogger, logger, :bodies => true)
      conn.adapter :test do |stub|
        stub.post('/path') {[201, {}, array_response]}
      end
    end

    it 'calls pretty print for that response' do
      expect_any_instance_of(Beaker::Http::FaradayBeakerLogger).to receive(:pretty_inspect).with(array_response).once.and_call_original
      expect(logger).to receive(:info).with('POST: http://test.com/path').once
      expect(logger).to receive(:info).with(/RESPONSE CODE: 201/).once
      expect(logger).to receive(:debug).with(/ELAPSED TIME:/).once
      expect(logger).to receive(:debug).with("RESPONSE BODY:\n[1, 2, 3]\n").once
      expect(logger).to receive(:debug).with(/REQUEST BODY:\nBODY MOVIN'/).once
      expect(logger).to receive(:debug).with(/REQUEST HEADERS:/).once
      expect(logger).to receive(:debug).with(/RESPONSE HEADERS:/).once
      conn.post() { |connection| connection.body = "BODY MOVIN'" }
    end
  end
end
