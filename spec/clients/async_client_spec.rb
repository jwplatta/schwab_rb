require 'async'
require 'async/rspec'
require 'json'
require_relative '../../lib/schwab_rb/clients/async_client'

RSpec.describe SchwabRb::AsyncClient do
  include Async::RSpec::Reactor

  let(:api_key) { 'test_api_key' }
  let(:app_secret) { 'test_app_secret' }
  let(:session) { double('session', token: 'test_token', expired?: false) }
  let(:token_manager) { double('token_manager', access_token: 'test_access_token') }
  let(:client) { described_class.new(api_key, app_secret, session, token_manager: token_manager) }

  after do
    client.close_async_session
  end

  describe '#initialize' do
    it 'sets up the async HTTP client with correct endpoint' do
      expect(client.instance_variable_get(:@client)).to be_a(Async::HTTP::Client)
      expect(client.instance_variable_get(:@endpoint).to_s).to include('api.schwabapi.com')
    end
  end

  describe '#get' do
    it 'sends a GET request and returns the response' do
      path = '/test_path'
      params = { key: 'value' }
      response = double('response', status: 200, body: 'response_body')

      allow(client).to receive(:refresh_token_if_needed)
      allow(client).to receive(:log_request)
      allow(client).to receive(:log_response)
      allow(client).to receive(:register_redactions_from_response)
      allow(client.instance_variable_get(:@client)).to receive(:get).and_return(response)

      async_task = client.send(:get, path, params)
      result = async_task.wait

      expect(result).to eq(response)
    end
  end

  describe '#post' do
    it 'sends a POST request and returns the response' do
      path = '/test_path'
      data = { key: 'value' }
      response = double('response', status: 200, body: 'response_body')

      allow(client).to receive(:refresh_token_if_needed)
      allow(client).to receive(:log_request)
      allow(client).to receive(:log_response)
      allow(client).to receive(:register_redactions_from_response)
      allow(client.instance_variable_get(:@client)).to receive(:post).and_return(response)

      async_task = client.send(:post, path, data)
      result = async_task.wait

      expect(result).to eq(response)
    end
  end

  describe '#put' do
    it 'sends a PUT request and returns the response' do
      path = '/test_path'
      data = { key: 'value' }
      response = double('response', status: 200, body: 'response_body')

      allow(client).to receive(:refresh_token_if_needed)
      allow(client).to receive(:log_request)
      allow(client).to receive(:log_response)
      allow(client).to receive(:register_redactions_from_response)
      allow(client.instance_variable_get(:@client)).to receive(:put).and_return(response)

      async_task = client.send(:put, path, data)
      result = async_task.wait

      expect(result).to eq(response)
    end
  end

  describe '#delete' do
    it 'sends a DELETE request and returns the response' do
      path = '/test_path'
      response = double('response', status: 200, body: 'response_body')

      allow(client).to receive(:refresh_token_if_needed)
      allow(client).to receive(:log_request)
      allow(client).to receive(:log_response)
      allow(client).to receive(:register_redactions_from_response)
      allow(client.instance_variable_get(:@client)).to receive(:delete).and_return(response)

      async_task = client.send(:delete, path)
      result = async_task.wait

      expect(result).to eq(response)
    end
  end

  describe '#build_headers' do
    it 'includes authorization header when token is available' do
      headers = client.send(:build_headers)
      
      expect(headers['Content-Type']).to eq('application/json')
      expect(headers['Authorization']).to eq('Bearer test_access_token')
    end
  end

  describe '#close_async_session' do
    it 'closes the HTTP client' do
      http_client = client.instance_variable_get(:@client)
      expect(http_client).to receive(:close).at_least(:once)
      
      client.close_async_session
    end
  end
end
