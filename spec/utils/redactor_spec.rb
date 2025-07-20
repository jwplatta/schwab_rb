require 'spec_helper'
require 'schwab_rb/utils/redactor'

describe SchwabRb::Redactor do
  describe '.redact_url' do
    it 'redacts account numbers in URLs' do
      url = 'https://api.schwabapi.com/trader/v1/accounts/123456789/orders'
      result = SchwabRb::Redactor.redact_url(url)
      expect(result).to eq('https://api.schwabapi.com/trader/v1/accounts/[REDACTED_ACCOUNT_NUMBER]/orders')
    end

    it 'redacts account hashes in URLs' do
      url = 'https://api.schwabapi.com/trader/v1/accounts/ABC123DEF456GHI789JKL012MNO345PQ/orders'
      result = SchwabRb::Redactor.redact_url(url)
      expect(result).to eq('https://api.schwabapi.com/trader/v1/accounts/[REDACTED_ACCOUNT_HASH]/orders')
    end

    it 'returns nil for nil input' do
      expect(SchwabRb::Redactor.redact_url(nil)).to be_nil
    end
  end

  describe '.redact_data' do
    it 'redacts sensitive keys in hash data' do
      data = { 
        'accountNumber' => '123456789',
        'accountHash' => 'ABC123DEF456GHI789JKL012MNO345PQ',
        'balance' => 50000 
      }
      result = SchwabRb::Redactor.redact_data(data)
      
      expect(result['accountNumber']).to eq('[REDACTED]')
      expect(result['accountHash']).to eq('[REDACTED]')
      expect(result['balance']).to eq(50000)
    end

    it 'redacts nested hash data' do
      data = {
        'account' => {
          'accountNumber' => '123456789',
          'type' => 'MARGIN'
        },
        'positions' => [
          {
            'symbol' => 'AAPL',
            'accountId' => '987654321'
          }
        ]
      }
      result = SchwabRb::Redactor.redact_data(data)
      
      expect(result['account']['accountNumber']).to eq('[REDACTED]')
      expect(result['account']['type']).to eq('MARGIN')
      expect(result['positions'][0]['accountId']).to eq('[REDACTED]')
      expect(result['positions'][0]['symbol']).to eq('AAPL')
    end

    it 'redacts JSON strings' do
      json_string = '{"accountNumber":"123456789","balance":50000}'
      result = SchwabRb::Redactor.redact_data(json_string)
      parsed = JSON.parse(result)
      
      expect(parsed['accountNumber']).to eq('[REDACTED]')
      expect(parsed['balance']).to eq(50000)
    end

    it 'redacts account patterns in regular strings' do
      string = 'Account 123456789 has a balance of $50000'
      result = SchwabRb::Redactor.redact_data(string)
      expect(result).to eq('Account [REDACTED_ACCOUNT_NUMBER] has a balance of $50000')
    end
  end

  describe '.redact_string' do
    it 'redacts account numbers' do
      string = 'Your account 123456789 is active'
      result = SchwabRb::Redactor.redact_string(string)
      expect(result).to eq('Your account [REDACTED_ACCOUNT_NUMBER] is active')
    end

    it 'redacts account hashes' do
      string = 'Hash: ABC123DEF456GHI789JKL012MNO345PQ'
      result = SchwabRb::Redactor.redact_string(string)
      expect(result).to eq('Hash: [REDACTED_ACCOUNT_HASH]')
    end

    it 'returns original string for non-string input' do
      expect(SchwabRb::Redactor.redact_string(123)).to eq(123)
      expect(SchwabRb::Redactor.redact_string(nil)).to be_nil
    end
  end

  describe '.redact_response_body' do
    it 'redacts JSON response bodies' do
      response = double('response')
      body = '{"accountNumber":"123456789","balance":50000}'
      allow(response).to receive(:body).and_return(body)
      
      result = SchwabRb::Redactor.redact_response_body(response)
      expect(result['accountNumber']).to eq('[REDACTED]')
      expect(result['balance']).to eq(50000)
    end

    it 'returns nil for responses without body method' do
      response = double('response')
      result = SchwabRb::Redactor.redact_response_body(response)
      expect(result).to be_nil
    end

    it 'returns nil for nil response' do
      result = SchwabRb::Redactor.redact_response_body(nil)
      expect(result).to be_nil
    end
  end
end
