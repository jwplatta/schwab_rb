# frozen_string_literal: true

require "json"
require "fileutils"

module SchwabRb
  class AccountHashManager
    class AccountNamesFileNotFoundError < StandardError; end
    class InvalidAccountNamesFileError < StandardError; end

    attr_reader :account_names_path, :account_names

    def initialize(account_names_path = nil, database: nil)
      @account_names_path = account_names_path || SchwabRb.configuration.account_names_path
      @account_names_path = File.expand_path(@account_names_path)
      @database = database
      @account_names = []
    end

    def update_hashes_from_api_response(account_numbers_response)
      account_names = load_account_names
      current_hashes = load_account_hashes

      number_to_hash = {}
      account_numbers_response.each do |account_data|
        account_number = account_data[:accountNumber]
        hash_value = account_data[:hashValue]
        number_to_hash[account_number] = hash_value
      end

      updated_accounts = []
      missing_accounts = []

      account_names.each do |name, account_number|
        if number_to_hash.key?(account_number)
          updated_accounts << {
            account_number: account_number,
            account_hash: number_to_hash[account_number],
            nickname: name
          }
        elsif (existing = current_hashes.find { |a| a[:nickname] == name })
          updated_accounts << existing
          missing_accounts << { name: name, number: account_number }
        else
          missing_accounts << { name: name, number: account_number }
        end
      end

      if missing_accounts.any?
        missing_accounts.each do |account|
          SchwabRb::Logger.logger.warn(
            "Account '#{account[:name]}' not found in API response. " \
            "This may indicate a closed account or incorrect account number in account_names.json"
          )
        end
      end

      save_account_hashes(updated_accounts)
      updated_accounts.to_h { |a| [a[:nickname], a[:account_hash]] }
    end

    def get_hash_by_name(account_name)
      accounts = load_account_hashes
      match = accounts.find { |a| a[:nickname] == account_name }
      match&.fetch(:account_hash, nil)
    end

    def get_all_hashes
      load_account_hashes.to_h { |a| [a[:nickname] || a[:account_number], a[:account_hash]] }
    end

    def available_account_names
      load_account_names.keys
    rescue AccountNamesFileNotFoundError
      []
    end

    private

    def effective_database
      @database || SchwabRb::Storage::Database.new
    end

    def load_account_hashes
      effective_database.load_accounts
    end

    def save_account_hashes(accounts)
      effective_database.save_accounts(accounts)
    end

    def load_account_names
      unless File.exist?(@account_names_path)
        raise AccountNamesFileNotFoundError,
              "Account names file not found at #{@account_names_path}. " \
              "Please create a JSON file mapping account names to account numbers. " \
              "Example: {\"my_trading_account\": \"12345678\", \"my_ira\": \"87654321\"}"
      end

      begin
        json_content = File.read(@account_names_path)
        return {} if json_content.strip.empty?

        account_names_hash = JSON.parse(json_content)
        @account_names = account_names_hash.keys
        account_names_hash
      rescue JSON::ParserError => e
        raise InvalidAccountNamesFileError,
              "Invalid JSON in account names file at #{@account_names_path}: #{e.message}"
      end
    end
  end
end
