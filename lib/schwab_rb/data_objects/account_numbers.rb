# frozen_string_literal: true

module SchwabRb
  module DataObjects
    class AccountNumbers
      attr_reader :accounts

      class << self
        def build(data)
          new(data)
        end
      end

      def initialize(data)
        @accounts = data.map { |account_data| AccountNumber.new(account_data) }
      end

      def to_h
        @accounts.map(&:to_h)
      end

      def find_by_account_number(account_number)
        @accounts.find { |account| account.account_number == account_number }
      end

      def find_hash_value(account_number)
        account = find_by_account_number(account_number)
        account&.hash_value
      end

      def account_numbers
        @accounts.map(&:account_number)
      end

      def hash_values
        @accounts.map(&:hash_value)
      end

      def size
        @accounts.size
      end

      def empty?
        @accounts.empty?
      end

      def each(&block)
        @accounts.each(&block)
      end

      class AccountNumber
        attr_reader :account_number, :hash_value

        def initialize(data)
          @account_number = data[:accountNumber]
          @hash_value = data[:hashValue]
        end

        def to_h
          {
            accountNumber: @account_number,
            hashValue: @hash_value
          }
        end
      end
    end
  end
end
