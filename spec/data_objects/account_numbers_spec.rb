# frozen_string_literal: true

require "spec_helper"
require "json"

RSpec.describe SchwabRb::DataObjects::AccountNumbers do
  let(:fixture_data) { JSON.parse(File.read("spec/fixtures/account_numbers.json"), symbolize_names: true) }
  let(:account_numbers) { described_class.build(fixture_data) }

  describe ".build" do
    it "creates an AccountNumbers instance from API response data" do
      expect(account_numbers).to be_a(described_class)
    end
  end

  describe "#initialize" do
    it "parses account data correctly" do
      expect(account_numbers.size).to eq(2)
      expect(account_numbers.account_numbers).to include("12345678", "12341234")
    end

    it "creates AccountNumber objects for each account" do
      account_numbers.each do |account|
        expect(account).to be_a(described_class::AccountNumber)
        expect(account.account_number).to be_a(String)
        expect(account.hash_value).to be_a(String)
      end
    end
  end

  describe "#find_by_account_number" do
    it "finds account by account number" do
      account = account_numbers.find_by_account_number("12345678")
      expect(account).to be_a(described_class::AccountNumber)
      expect(account.account_number).to eq("12345678")
      expect(account.hash_value).to eq("1996EA061B4878E8D0B9063DF74925E5688F475BE00AF6A0A41E1FC4A2510XA0")
    end

    it "returns nil for non-existent account number" do
      account = account_numbers.find_by_account_number("99999999")
      expect(account).to be_nil
    end
  end

  describe "#find_hash_value" do
    it "returns hash value for valid account number" do
      hash_value = account_numbers.find_hash_value("12341234")
      expect(hash_value).to eq("DAC7D21C00C8A5086918EA91173D60302A704FFE4CF3731E7709F18F8CE948F2")
    end

    it "returns nil for invalid account number" do
      hash_value = account_numbers.find_hash_value("99999999")
      expect(hash_value).to be_nil
    end
  end

  describe "#account_numbers" do
    it "returns array of all account numbers" do
      numbers = account_numbers.account_numbers
      expect(numbers).to be_a(Array)
      expect(numbers).to contain_exactly("12345678", "12341234")
    end
  end

  describe "#hash_values" do
    it "returns array of all hash values" do
      hashes = account_numbers.hash_values
      expect(hashes).to be_a(Array)
      expect(hashes.size).to eq(2)
      hashes.each { |hash| expect(hash).to be_a(String) }
    end
  end

  describe "#size" do
    it "returns number of accounts" do
      expect(account_numbers.size).to eq(2)
    end
  end

  describe "#empty?" do
    it "returns false when accounts exist" do
      expect(account_numbers.empty?).to be false
    end

    it "returns true for empty account list" do
      empty_accounts = described_class.build([])
      expect(empty_accounts.empty?).to be true
    end
  end

  describe "#to_h" do
    it "returns hash representation matching original API data" do
      hash_data = account_numbers.to_h
      expect(hash_data).to be_a(Array)
      expect(hash_data.size).to eq(2)

      first_account = hash_data.first
      expect(first_account).to have_key(:accountNumber)
      expect(first_account).to have_key(:hashValue)
    end
  end

  describe "#each" do
    it "iterates over all accounts" do
      accounts = account_numbers.map { |account| account }
      expect(accounts.size).to eq(2)
      accounts.each { |account| expect(account).to be_a(described_class::AccountNumber) }
    end
  end

  describe "AccountNumber" do
    let(:account_data) { { accountNumber: "12345678", hashValue: "ABC123" } }
    let(:account) { described_class::AccountNumber.new(account_data) }

    describe "#initialize" do
      it "sets account number and hash value" do
        expect(account.account_number).to eq("12345678")
        expect(account.hash_value).to eq("ABC123")
      end
    end

    describe "#to_h" do
      it "returns hash with symbolized keys" do
        hash_data = account.to_h
        expect(hash_data).to eq({
                                  accountNumber: "12345678",
                                  hashValue: "ABC123"
                                })
      end
    end
  end
end
