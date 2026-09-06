# frozen_string_literal: true

require "fileutils"
require "json"
require_relative "../lib/schwab_rb"

describe SchwabRb::AccountHashManager do
  let(:test_dir) { "tmp/test_account_manager" }
  let(:account_names_path) { "#{test_dir}/account_names.json" }
  let(:database) { SchwabRb::Storage::Database.new(":memory:") }

  let(:account_names) do
    {
      "trading_account" => "12345678",
      "ira_account" => "87654321"
    }
  end

  let(:api_response) do
    [
      { accountNumber: "12345678", hashValue: "HASH123" },
      { accountNumber: "87654321", hashValue: "HASH456" }
    ]
  end

  before do
    FileUtils.mkdir_p(test_dir)
    File.write(account_names_path, JSON.pretty_generate(account_names))
  end

  after do
    FileUtils.rm_rf(test_dir)
    database.close
  end

  it "loads account names from file" do
    manager = described_class.new(account_names_path, database: database)
    names = manager.available_account_names

    expect(names).to contain_exactly("trading_account", "ira_account")
  end

  it "handles missing account names file gracefully" do
    manager = described_class.new("#{test_dir}/nonexistent.json", database: database)
    names = manager.available_account_names

    expect(names).to eq([])
  end

  it "updates and saves hashes from API response" do
    manager = described_class.new(account_names_path, database: database)
    updated_hashes = manager.update_hashes_from_api_response(api_response)

    expect(updated_hashes).to eq({
      "trading_account" => "HASH123",
      "ira_account" => "HASH456"
    })
  end

  it "persists account hashes to the database" do
    manager = described_class.new(account_names_path, database: database)
    manager.update_hashes_from_api_response(api_response)

    accounts = database.load_accounts
    expect(accounts.length).to eq(2)
    expect(accounts.map { |a| a[:account_hash] }).to contain_exactly("HASH123", "HASH456")
  end

  it "retrieves hash by account name" do
    database.save_accounts([
      { account_number: "12345678", account_hash: "HASH123", nickname: "trading_account" }
    ])

    manager = described_class.new(account_names_path, database: database)
    hash_value = manager.get_hash_by_name("trading_account")

    expect(hash_value).to eq("HASH123")
  end

  it "returns nil for non-existent account name" do
    database.save_accounts([
      { account_number: "12345678", account_hash: "HASH123", nickname: "trading_account" }
    ])

    manager = described_class.new(account_names_path, database: database)
    hash_value = manager.get_hash_by_name("nonexistent")

    expect(hash_value).to be_nil
  end

  it "returns available account names" do
    manager = described_class.new(account_names_path, database: database)
    names = manager.available_account_names

    expect(names).to contain_exactly("trading_account", "ira_account")
  end

  it "returns empty array when account names file doesn't exist" do
    manager = described_class.new("#{test_dir}/nonexistent.json", database: database)
    names = manager.available_account_names

    expect(names).to eq([])
  end
end
