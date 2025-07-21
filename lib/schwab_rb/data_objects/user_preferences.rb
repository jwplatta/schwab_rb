# frozen_string_literal: true

module SchwabRb
  module DataObjects
    class UserPreferences
      attr_reader :accounts, :streamer_info, :offers

      class << self
        def build(data)
          new(data)
        end
      end

      def initialize(data)
        @accounts = data[:accounts]&.map { |account_data| UserAccount.new(account_data) } || []
        @streamer_info = data[:streamerInfo]&.map { |streamer_data| StreamerInfo.new(streamer_data) } || []
        @offers = data[:offers]&.map { |offer_data| Offer.new(offer_data) } || []
      end

      def to_h
        {
          accounts: @accounts.map(&:to_h),
          streamerInfo: @streamer_info.map(&:to_h),
          offers: @offers.map(&:to_h)
        }
      end

      def primary_account
        @accounts.find(&:primary_account?)
      end

      def find_account_by_number(account_number)
        @accounts.find { |account| account.account_number == account_number }
      end

      def account_numbers
        @accounts.map(&:account_number)
      end

      def brokerage_accounts
        @accounts.select { |account| account.type == "BROKERAGE" }
      end

      def has_level2_permissions?
        @offers.any?(&:level2_permissions?)
      end

      class UserAccount
        attr_reader :account_number, :primary_account, :type, :nick_name, :display_acct_id,
                    :auto_position_effect, :account_color, :lot_selection_method

        def initialize(data)
          @account_number = data[:accountNumber]
          @primary_account = data[:primaryAccount]
          @type = data[:type]
          @nick_name = data[:nickName]
          @display_acct_id = data[:displayAcctId]
          @auto_position_effect = data[:autoPositionEffect]
          @account_color = data[:accountColor]
          @lot_selection_method = data[:lotSelectionMethod]
        end

        def primary_account?
          @primary_account
        end

        def auto_position_effect?
          @auto_position_effect
        end

        def to_h
          {
            accountNumber: @account_number,
            primaryAccount: @primary_account,
            type: @type,
            nickName: @nick_name,
            displayAcctId: @display_acct_id,
            autoPositionEffect: @auto_position_effect,
            accountColor: @account_color,
            lotSelectionMethod: @lot_selection_method
          }
        end
      end

      class StreamerInfo
        attr_reader :streamer_socket_url, :schwab_client_customer_id, :schwab_client_correl_id,
                    :schwab_client_channel, :schwab_client_function_id

        def initialize(data)
          @streamer_socket_url = data[:streamerSocketUrl]
          @schwab_client_customer_id = data[:schwabClientCustomerId]
          @schwab_client_correl_id = data[:schwabClientCorrelId]
          @schwab_client_channel = data[:schwabClientChannel]
          @schwab_client_function_id = data[:schwabClientFunctionId]
        end

        def to_h
          {
            streamerSocketUrl: @streamer_socket_url,
            schwabClientCustomerId: @schwab_client_customer_id,
            schwabClientCorrelId: @schwab_client_correl_id,
            schwabClientChannel: @schwab_client_channel,
            schwabClientFunctionId: @schwab_client_function_id
          }
        end
      end

      class Offer
        attr_reader :level2_permissions, :mkt_data_permission

        def initialize(data)
          @level2_permissions = data[:level2Permissions]
          @mkt_data_permission = data[:mktDataPermission]
        end

        def level2_permissions?
          @level2_permissions
        end

        def to_h
          {
            level2Permissions: @level2_permissions,
            mktDataPermission: @mkt_data_permission
          }
        end
      end
    end
  end
end
