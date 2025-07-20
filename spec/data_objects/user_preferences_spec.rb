# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe SchwabRb::DataObjects::UserPreferences do
  let(:fixture_data) { JSON.parse(File.read('spec/fixtures/user_preferences.json'), symbolize_names: true) }
  let(:user_preferences) { described_class.build(fixture_data) }

  describe '.build' do
    it 'creates a UserPreferences instance from API response data' do
      expect(user_preferences).to be_a(described_class)
    end
  end

  describe '#initialize' do
    it 'parses accounts data correctly' do
      expect(user_preferences.accounts.size).to eq(2)
      expect(user_preferences.accounts.first).to be_a(described_class::UserAccount)
    end

    it 'parses streamer info correctly' do
      expect(user_preferences.streamer_info.size).to eq(1)
      expect(user_preferences.streamer_info.first).to be_a(described_class::StreamerInfo)
    end

    it 'parses offers data correctly' do
      expect(user_preferences.offers.size).to eq(1)
      expect(user_preferences.offers.first).to be_a(described_class::Offer)
    end
  end

  describe '#primary_account' do
    it 'returns nil when no primary account is set' do
      expect(user_preferences.primary_account).to be_nil
    end

    context 'when primary account exists' do
      let(:data_with_primary) do
        fixture_data.dup.tap do |data|
          data[:accounts][0][:primaryAccount] = true
        end
      end
      let(:preferences_with_primary) { described_class.build(data_with_primary) }

      it 'returns the primary account' do
        primary = preferences_with_primary.primary_account
        expect(primary).to be_a(described_class::UserAccount)
        expect(primary.primary_account?).to be true
      end
    end
  end

  describe '#find_account_by_number' do
    it 'finds account by account number' do
      account = user_preferences.find_account_by_number('11221122')
      expect(account).to be_a(described_class::UserAccount)
      expect(account.nick_name).to eq('Trading Brokerage')
    end

    it 'returns nil for non-existent account number' do
      account = user_preferences.find_account_by_number('99999999')
      expect(account).to be_nil
    end
  end

  describe '#account_numbers' do
    it 'returns array of all account numbers' do
      numbers = user_preferences.account_numbers
      expect(numbers).to contain_exactly('11221122', '12345678')
    end
  end

  describe '#brokerage_accounts' do
    it 'returns only brokerage accounts' do
      accounts = user_preferences.brokerage_accounts
      expect(accounts.size).to eq(2)
      accounts.each { |account| expect(account.type).to eq('BROKERAGE') }
    end
  end

  describe '#has_level2_permissions?' do
    it 'returns true when level2 permissions are granted' do
      expect(user_preferences.has_level2_permissions?).to be true
    end

    context 'when no level2 permissions' do
      let(:data_without_level2) do
        fixture_data.dup.tap do |data|
          data[:offers][0][:level2Permissions] = false
        end
      end
      let(:preferences_without_level2) { described_class.build(data_without_level2) }

      it 'returns false' do
        expect(preferences_without_level2.has_level2_permissions?).to be false
      end
    end
  end

  describe '#to_h' do
    it 'returns hash representation matching original API data structure' do
      hash_data = user_preferences.to_h
      expect(hash_data).to have_key(:accounts)
      expect(hash_data).to have_key(:streamerInfo)
      expect(hash_data).to have_key(:offers)
      
      expect(hash_data[:accounts]).to be_a(Array)
      expect(hash_data[:streamerInfo]).to be_a(Array)
      expect(hash_data[:offers]).to be_a(Array)
    end
  end

  describe 'UserAccount' do
    let(:account_data) { fixture_data[:accounts].first }
    let(:account) { described_class::UserAccount.new(account_data) }

    describe '#initialize' do
      it 'sets all account attributes' do
        expect(account.account_number).to eq('11221122')
        expect(account.type).to eq('BROKERAGE')
        expect(account.nick_name).to eq('Trading Brokerage')
        expect(account.display_acct_id).to eq('...122')
        expect(account.account_color).to eq('Green')
        expect(account.lot_selection_method).to eq('FIFO')
        expect(account.primary_account).to be false
        expect(account.auto_position_effect).to be false
      end
    end

    describe '#primary_account?' do
      it 'returns boolean value' do
        expect(account.primary_account?).to be(false)
      end
    end

    describe '#auto_position_effect?' do
      it 'returns boolean value' do
        expect(account.auto_position_effect?).to be(false)
      end
    end

    describe '#to_h' do
      it 'returns hash with symbolized keys' do
        hash_data = account.to_h
        expect(hash_data[:accountNumber]).to eq('11221122')
        expect(hash_data[:type]).to eq('BROKERAGE')
        expect(hash_data[:nickName]).to eq('Trading Brokerage')
      end
    end
  end

  describe 'StreamerInfo' do
    let(:streamer_data) { fixture_data[:streamerInfo].first }
    let(:streamer) { described_class::StreamerInfo.new(streamer_data) }

    describe '#initialize' do
      it 'sets all streamer attributes' do
        expect(streamer.streamer_socket_url).to eq('wss://streamer-api.schwab.com/ws')
        expect(streamer.schwab_client_customer_id).to be_a(String)
        expect(streamer.schwab_client_correl_id).to be_a(String)
        expect(streamer.schwab_client_channel).to eq('N9')
        expect(streamer.schwab_client_function_id).to eq('APIAPP')
      end
    end

    describe '#to_h' do
      it 'returns hash with symbolized keys' do
        hash_data = streamer.to_h
        expect(hash_data[:streamerSocketUrl]).to eq('wss://streamer-api.schwab.com/ws')
        expect(hash_data[:schwabClientChannel]).to eq('N9')
        expect(hash_data[:schwabClientFunctionId]).to eq('APIAPP')
      end
    end
  end

  describe 'Offer' do
    let(:offer_data) { fixture_data[:offers].first }
    let(:offer) { described_class::Offer.new(offer_data) }

    describe '#initialize' do
      it 'sets all offer attributes' do
        expect(offer.level2_permissions).to be true
        expect(offer.mkt_data_permission).to eq('NP')
      end
    end

    describe '#level2_permissions?' do
      it 'returns boolean value' do
        expect(offer.level2_permissions?).to be true
      end
    end

    describe '#to_h' do
      it 'returns hash with symbolized keys' do
        hash_data = offer.to_h
        expect(hash_data[:level2Permissions]).to be true
        expect(hash_data[:mktDataPermission]).to eq('NP')
      end
    end
  end
end
