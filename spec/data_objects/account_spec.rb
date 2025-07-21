# frozen_string_literal: true

require "rspec"
require "schwab_rb"
require "schwab_rb"

RSpec.describe SchwabRb::DataObjects::Account do
  let(:raw_data) do
    JSON.parse(File.read("spec/fixtures/account.json"), symbolize_names: true)
  end

  describe ".from_raw" do
    it "creates an option chain object from raw data" do
      account = SchwabRb::DataObjects::Account.build(raw_data)
      expect(account).to be_an_instance_of SchwabRb::DataObjects::Account
      expect(account.type).to eq "MARGIN"
      expect(account.account_number).to eq "11111111"
      expect(account.round_trips).to eq 0
      expect(account.is_closing_only_restricted).to be false
      expect(account.pfcb_flag).to be false
      expect(account.positions).to be_an_instance_of Array
      expect(account.positions.size).to eq 10
      expect(account.positions.first).to be_an_instance_of SchwabRb::DataObjects::Position
      expect(account.positions.first.instrument).to be_an_instance_of SchwabRb::DataObjects::Instrument
      expect(account.initial_balances).to be_an_instance_of SchwabRb::DataObjects::InitialBalances
      expect(account.current_balances).to be_an_instance_of SchwabRb::DataObjects::CurrentBalances
      expect(account.projected_balances).to be_an_instance_of SchwabRb::DataObjects::ProjectedBalances
    end
  end
end
