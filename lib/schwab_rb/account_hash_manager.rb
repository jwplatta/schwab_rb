# frozen_string_literal: true

require "json"
require "fileutils"

module SchwabRb
  class AccountHashManager
    class AccountNamesFileNotFoundError < StandardError; end
    class InvalidAccountNamesFileError < StandardError; end

    attr_reader :account_names_path, :account_hashes_path, :account_names

    def initialize(account_names_path = nil, account_hashes_path = nil)
      @account_names_path = account_names_path || SchwabRb.configuration.account_names_path
      @account_hashes_path = account_hashes_path || SchwabRb.configuration.account_hashes_path
      @account_names_path = File.expand_path(@account_names_path)
      @account_hashes_path = File.expand_path(@account_hashes_path)
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

      updated_hashes = {}
      missing_accounts = []

      account_names.each do |name, account_number|
        if number_to_hash.key?(account_number)
          updated_hashes[name] = number_to_hash[account_number]
        elsif current_hashes.key?(name)
          # Keep existing hash but warn that account wasn't in API response
          updated_hashes[name] = current_hashes[name]
          missing_accounts << { name: name, number: account_number }
        else
          # Account name exists but no hash found (new or invalid account)
          missing_accounts << { name: name, number: account_number }
        end
      end

      # Log warnings for accounts that weren't found in API response
      if missing_accounts.any?
        missing_accounts.each do |account|
          SchwabRb::Logger.logger.warn(
            "Account '#{account[:name]}' (#{account[:number]}) not found in API response. " \
            "This may indicate a closed account or incorrect account number in account_names.json"
          )
        end
      end

      save_account_hashes(updated_hashes)
      updated_hashes
    end

    # Get account hash by name
    def get_hash_by_name(account_name)
      hashes = load_account_hashes
      hashes[account_name]
    end

    # Get all account hashes
    def get_all_hashes
      load_account_hashes
    end

    # Get list of available account names from account_names.json
    def available_account_names
      begin
        load_account_names.keys
      rescue AccountNamesFileNotFoundError
        []
      end
    end

    private

    def load_account_hashes
      return {} unless File.exist?(@account_hashes_path)

      begin
        json_content = File.read(@account_hashes_path)
        JSON.parse(json_content)
      rescue JSON::ParserError
        {}
      end
    end

    def save_account_hashes(hashes_map)
      FileUtils.mkdir_p(File.dirname(@account_hashes_path))

      File.write(@account_hashes_path, JSON.pretty_generate(hashes_map))
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
