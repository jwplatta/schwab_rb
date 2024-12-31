require 'async'
require 'async/rspec'
require 'json'
require_relative '../../lib/schwab_rb/clients/async_client'

RSpec.describe SchwabRb::AsyncClient do
  include Async::RSpec::Reactor

  let(:api_key) { 'test_api_key' }
  let(:app_secret) { 'test_app_secret' }
  let(:session) { double('session', token: 'test_token', expired?: false) }
  let(:token_manager) { double('token_manager') }
  let(:client) { described_class.new(api_key, app_secret, session, token_manager: token_manager) }

  after do
    client.close_async_session
  end

  describe '#get' do
    it 'sends a GET request and returns the response' do
      path = '/test_path'
      params = { key: 'value' }
      response = double('response', body: 'response_body')

      allow(client).to receive(:log_request)
      allow(client).to receive(:log_response)
      allow(client).to receive(:register_redactions_from_response)
      allow(client.instance_variable_get(:@client)).to receive(:get).and_return(response)

      result = client.get(path, params).wait

      expect(result).to eq(response)
    end
  end

  describe '#post' do
    it 'sends a POST request and returns the response' do
      path = '/test_path'
      data = { key: 'value' }
      response = double('response', body: 'response_body')

      allow(client).to receive(:log_request)
      allow(client).to receive(:log_response)
      allow(client).to receive(:register_redactions_from_response)
      allow(client.instance_variable_get(:@client)).to receive(:post).and_return(response)

      result = client.post(path, data).wait

      expect(result).to eq(response)
    end
  end

  describe '#put' do
    it 'sends a PUT request and returns the response' do
      path = '/test_path'
      data = { key: 'value' }
      response = double('response', body: 'response_body')

      allow(client).to receive(:log_request)
      allow(client).to receive(:log_response)
      allow(client).to receive(:register_redactions_from_response)
      allow(client.instance_variable_get(:@client)).to receive(:put).and_return(response)

      result = client.put(path, data).wait

      expect(result).to eq(response)
    end
  end

  describe '#delete' do
    it 'sends a DELETE request and returns the response' do
      path = '/test_path'
      response = double('response', body: 'response_body')

      allow(client).to receive(:log_request)
      allow(client).to receive(:log_response)
      allow(client).to receive(:register_redactions_from_response)
      allow(client.instance_variable_get(:@client)).to receive(:delete).and_return(response)

      result = client.delete(path).wait

      expect(result).to eq(response)
    end
  end
end
