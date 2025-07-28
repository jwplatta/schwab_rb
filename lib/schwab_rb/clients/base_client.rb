# frozen_string_literal: true

require "date"
require "json"
require_relative "../utils/enum_enforcer"
require_relative "../data_objects/account"
require_relative "../data_objects/account_numbers"
require_relative "../data_objects/user_preferences"
require_relative "../data_objects/option_expiration_chain"
require_relative "../data_objects/price_history"
require_relative "../data_objects/market_hours"
require_relative "../data_objects/quote"
require_relative "../data_objects/transaction"
require_relative "../data_objects/order"
require_relative "../data_objects/market_movers"

module SchwabRb
  class BaseClient
    include EnumEnforcer

    attr_reader :api_key, :app_secret, :session, :token_manager, :enforce_enums

    def initialize(api_key, app_secret, session, token_manager:, enforce_enums: true)
      @api_key = api_key
      @app_secret = app_secret
      @session = session
      @token_manager = token_manager
      @enforce_enums = enforce_enums
    end

    def refresh!
      refresh_token_if_needed
    end

    def timeout
      @session.options[:connection_opts][:request][:timeout]
    end

    def set_timeout(timeout)
      # Sets the timeout for the client session.
      #
      # @param timeout [Integer] The timeout value in seconds.
      @session.options[:connection_opts] ||= {}
      @session.options[:connection_opts][:request] ||= {}
      @session.options[:connection_opts][:request][:timeout] = timeout
    end

    def token_age
      @token_manager.token_age
    end

    def get_account(account_hash, fields: nil, return_data_objects: true)
      # Account balances, positions, and orders for a given account hash.
      #
      # @param fields [Array] Balances displayed by default, additional fields can be
      # added here by adding values from Account.fields.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      fields = convert_enum_iterable(fields, SchwabRb::Account::Statuses) if fields

      params = {}
      params[:fields] = fields.join(",") if fields

      path = "/trader/v1/accounts/#{account_hash}"
      response = get(path, params)

      if return_data_objects
        account_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::Account.build(account_data)
      else
        response
      end
    end

    def get_accounts(fields: nil, return_data_objects: true)
      # Account balances, positions, and orders for all linked accounts.
      #
      # Note: This method does not return account hashes.
      #
      # @param fields [Array] Balances displayed by default, additional fields can be
      # added here by adding values from Account.fields.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      fields = convert_enum_iterable(fields, SchwabRb::Account::Statuses) if fields

      params = {}
      params[:fields] = fields.join(",") if fields

      path = "/trader/v1/accounts"
      response = get(path, params)

      if return_data_objects
        accounts_data = JSON.parse(response.body, symbolize_names: true)
        accounts_data.map { |account_data| SchwabRb::DataObjects::Account.build(account_data) }
      else
        response
      end
    end

    def get_account_numbers(return_data_objects: true)
      # Returns a mapping from account IDs available to this token to the
      # account hash that should be passed whenever referring to that account
      # in API calls.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      path = "/trader/v1/accounts/accountNumbers"
      response = get(path, {})

      if return_data_objects
        account_numbers_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::AccountNumbers.build(account_numbers_data)
      else
        response
      end
    end

    def get_order(order_id, account_hash, return_data_objects: true)
      # Get a specific order for a specific account by its order ID.
      #
      # @param order_id [String] The order ID.
      # @param account_hash [String] The account hash.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      path = "/trader/v1/accounts/#{account_hash}/orders/#{order_id}"
      response = get(path, {})

      if return_data_objects
        order_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::Order.build(order_data)
      else
        response
      end
    end

    def cancel_order(order_id, account_hash)
      # Cancel a specific order for a specific account.
      #
      # @param order_id [String] The order ID.
      # @param account_hash [String] The account hash.
      refresh_token_if_needed

      path = "/trader/v1/accounts/#{account_hash}/orders/#{order_id}"
      delete(path)
    end

    def get_account_orders(
      account_hash,
      max_results: nil,
      from_entered_datetime: nil,
      to_entered_datetime: nil,
      status: nil,
      return_data_objects: true
    )
      # Orders for a specific account. Optionally specify a single status on which to filter.
      #
      # @param max_results [Integer] The maximum number of orders to retrieve.
      # @param from_entered_datetime [DateTime] Start of the query date range (default: 60 days ago).
      # @param to_entered_datetime [DateTime] End of the query date range (default: now).
      # @param status [String] Restrict query to orders with this status.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      from_entered_datetime = DateTime.now.new_offset(0) - 60 if from_entered_datetime.nil?

      to_entered_datetime = DateTime.now if to_entered_datetime.nil?

      status = convert_enum(status, SchwabRb::Order::Statuses) if status

      path = "/trader/v1/accounts/#{account_hash}/orders"
      params = make_order_query(
        max_results: max_results,
        from_entered_datetime: from_entered_datetime,
        to_entered_datetime: to_entered_datetime,
        status: status
      )

      response = get(path, params)

      if return_data_objects
        orders_data = JSON.parse(response.body, symbolize_names: true)
        orders_data.map { |order_data| SchwabRb::DataObjects::Order.build(order_data) }
      else
        response
      end
    end

    def get_all_linked_account_orders(
      max_results: nil,
      from_entered_datetime: nil,
      to_entered_datetime: nil,
      status: nil,
      return_data_objects: true
    )
      # Orders for all linked accounts. Optionally specify a single status on which to filter.
      #
      # @param max_results [Integer] The maximum number of orders to retrieve.
      # @param from_entered_datetime [DateTime] Start of the query date range (default: 60 days ago).
      # @param to_entered_datetime [DateTime] End of the query date range (default: now).
      # @param status [String] Restrict query to orders with this status.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      path = "/trader/v1/orders"
      params = make_order_query(
        max_results: max_results,
        from_entered_datetime: from_entered_datetime,
        to_entered_datetime: to_entered_datetime,
        status: status
      )

      response = get(path, params)

      if return_data_objects
        orders_data = JSON.parse(response.body, symbolize_names: true)
        orders_data.map { |order_data| SchwabRb::DataObjects::Order.build(order_data) }
      else
        response
      end
    end

    def place_order(account_hash, order_spec)
      # Place an order for a specific account. If order creation is successful,
      # the response will contain the ID of the generated order.
      #
      # Note: Unlike most methods in this library, successful responses typically
      # do not contain JSON data, and attempting to extract it may raise an exception.
      refresh_token_if_needed

      order_spec = order_spec.build if order_spec.is_a?(SchwabRb::Orders::Builder)

      path = "/trader/v1/accounts/#{account_hash}/orders"
      post(path, order_spec)
    end

    def replace_order(account_hash, order_id, order_spec)
      # Replace an existing order for an account.
      # The existing order will be replaced by the new order.
      # Once replaced, the old order will be canceled and a new order will be created.
      refresh_token_if_needed

      order_spec = order_spec.build if order_spec.is_a?(SchwabRb::Orders::Builder)

      path = "/trader/v1/accounts/#{account_hash}/orders/#{order_id}"
      put(path, order_spec)
    end

    def preview_order(account_hash, order_spec, return_data_objects: true)
      # Preview an order, i.e., test whether an order would be accepted by the
      # API and see the structure it would result in.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      order_spec = order_spec.build if order_spec.is_a?(SchwabRb::Orders::Builder)

      path = "/trader/v1/accounts/#{account_hash}/previewOrder"
      response = post(path, order_spec)

      if return_data_objects
        preview_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::OrderPreview.build(preview_data)
      else
        response
      end
    end

    def get_transactions(
      account_hash,
      start_date: nil,
      end_date: nil,
      transaction_types: nil,
      symbol: nil,
      return_data_objects: true
    )
      # Transactions for a specific account.
      #
      # @param account_hash [String] Account hash corresponding to the account.
      # @param start_date [Date, DateTime] Start date for transactions (default: 60 days ago).
      # @param end_date [Date, DateTime] End date for transactions (default: now).
      # @param transaction_types [Array] List of transaction types to filter by.
      # @param symbol [String] Filter transactions by the specified symbol.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      transaction_types = if transaction_types
                            convert_enum_iterable(transaction_types, SchwabRb::Transaction::Types)
      else
        get_valid_enum_values(SchwabRb::Transaction::Types)
                          end

      start_date = if start_date.nil?
                     format_date_as_iso("start_date", DateTime.now.new_offset(0) - 60)
      else
        format_date_as_iso("start_date", start_date)
                   end

      end_date = if end_date.nil?
                   format_date_as_iso("end_date", DateTime.now.new_offset(0))
      else
        format_date_as_iso("end_date", end_date)
                 end

      params = {
        "types" => transaction_types.sort.join(","),
        "startDate" => start_date,
        "endDate" => end_date
      }
      params["symbol"] = symbol unless symbol.nil?

      path = "/trader/v1/accounts/#{account_hash}/transactions"
      response = get(path, params)

      if return_data_objects
        transactions_data = JSON.parse(response.body, symbolize_names: true)
        transactions_data.map do |transaction_data|
          SchwabRb::DataObjects::Transaction.build(transaction_data)
        end
      else
        response
      end
    end

    def get_transaction(account_hash, activity_id, return_data_objects: true)
      # Transaction for a specific account.
      #
      # @param account_hash [String] Account hash corresponding to the account whose
      #                              transactions should be returned.
      # @param activity_id [String] ID of the order for which to return data.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      path = "/trader/v1/accounts/#{account_hash}/transactions/#{activity_id}"
      response = get(path, {})

      if return_data_objects
        transaction_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::Transaction.build(transaction_data)
      else
        response
      end
    end

    def get_user_preferences(return_data_objects: true)
      # Get user preferences for the authenticated user.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed
      path = "/trader/v1/userPreference"
      response = get(path, {})

      if return_data_objects
        preferences_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::UserPreferences.build(preferences_data)
      else
        response
      end
    end

    def get_quote(symbol, fields: nil, return_data_objects: true)
      # Get quote for a symbol.
      #
      # @param symbol [String] Single symbol to fetch.
      # @param fields [Array] Fields to request. If unset, return all available
      #                       data (i.e., all fields). See `GetQuote::Field` for options.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      fields = convert_enum_iterable(fields, SchwabRb::Quote::Types) if fields
      params = fields ? { "fields" => fields.join(",") } : {}
      path = "/marketdata/v1/#{symbol}/quotes"
      response = get(path, params)

      if return_data_objects
        quote_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::QuoteFactory.build(quote_data)
      else
        response
      end
    end

    def get_quotes(symbols, fields: nil, indicative: nil, return_data_objects: true)
      # Get quotes for symbols. This method supports all symbols, including those
      # containing non-alphanumeric characters like `/ES`.
      #
      # @param symbols [Array, String] Symbols to fetch. Can be a single symbol or an array of symbols.
      # @param fields [Array] Fields to request. If unset, return all available data.
      #                       See `GetQuote::Field` for options.
      # @param indicative [Boolean] If set, fetch indicative quotes. Must be true or false.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      symbols = [symbols] if symbols.is_a?(String)
      params = { "symbols" => symbols.join(",") }
      fields = convert_enum_iterable(fields, SchwabRb::Quote::Types) if fields
      params["fields"] = fields.join(",") if fields

      unless indicative.nil?
        unless [true, false].include?(indicative)
          raise ArgumentError, "value of 'indicative' must be either true or false"
        end

        params["indicative"] = indicative ? "true" : "false"
      end

      path = "/marketdata/v1/quotes"
      response = get(path, params)

      if return_data_objects
        quotes_data = JSON.parse(response.body, symbolize_names: true)
        quotes_data.map do |symbol, quote_data|
          SchwabRb::DataObjects::QuoteFactory.build({ symbol => quote_data })
        end
      else
        response
      end
    end

    def get_option_chain(
      symbol,
      contract_type: nil,
      strike_count: nil,
      include_underlying_quote: nil,
      strategy: nil,
      interval: nil,
      strike: nil,
      strike_range: nil,
      from_date: nil,
      to_date: nil,
      volatility: nil,
      underlying_price: nil,
      interest_rate: nil,
      days_to_expiration: nil,
      exp_month: nil,
      option_type: nil,
      entitlement: nil,
      return_data_objects: true
    )
      # Get option chain for an optionable symbol.
      #
      # @param symbol [String] The symbol for the option chain.
      # @param contract_type [String] Type of contracts to return in the chain.
      # @param strike_count [Integer] Number of strikes above and below the ATM price.
      # @param include_underlying_quote [Boolean] Include a quote for the underlying.
      # @param strategy [String] Strategy type for the option chain.
      # @param interval [Float] Strike interval for spread strategy chains.
      # @param strike [Float] Specific strike price for the option chain.
      # @param strike_range [String] Range of strikes to include.
      # @param from_date [Date] Filter expirations after this date.
      # @param to_date [Date] Filter expirations before this date.
      # @param volatility [Float] Volatility for analytical calculations.
      # @param underlying_price [Float] Underlying price for analytical calculations.
      # @param interest_rate [Float] Interest rate for analytical calculations.
      # @param days_to_expiration [Integer] Days to expiration for analytical calculations.
      # @param exp_month [String] Filter options by expiration month.
      # @param option_type [String] Type of options to include in the chain.
      # @param entitlement [String] Client entitlement.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON

      refresh_token_if_needed

      contract_type = convert_enum(contract_type, SchwabRb::Option::ContractTypes)
      strategy = convert_enum(strategy, SchwabRb::Option::Strategies)
      strike_range = convert_enum(strike_range, SchwabRb::Option::StrikeRanges)
      option_type = convert_enum(option_type, SchwabRb::Option::Types)
      exp_month = convert_enum(exp_month, SchwabRb::Option::ExpirationMonths)
      entitlement = convert_enum(entitlement, SchwabRb::Option::Entitlements)

      params = { "symbol" => symbol }
      params["contractType"] = contract_type if contract_type
      params["strikeCount"] = strike_count if strike_count
      params["includeUnderlyingQuote"] = include_underlying_quote if include_underlying_quote
      params["strategy"] = strategy if strategy
      params["interval"] = interval if interval
      params["strike"] = strike if strike
      params["range"] = strike_range if strike_range
      params["fromDate"] = format_date_as_day("from_date", from_date) if from_date
      params["toDate"] = format_date_as_day("to_date", to_date) if to_date
      params["volatility"] = volatility if volatility
      params["underlyingPrice"] = underlying_price if underlying_price
      params["interestRate"] = interest_rate if interest_rate
      params["daysToExpiration"] = days_to_expiration if days_to_expiration
      params["expMonth"] = exp_month if exp_month
      params["optionType"] = option_type if option_type
      params["entitlement"] = entitlement if entitlement

      path = "/marketdata/v1/chains"
      response = get(path, params)

      if return_data_objects
        option_chain_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::OptionChain.build(option_chain_data)
      else
        response
      end
    end

    def get_option_expiration_chain(symbol, return_data_objects: true)
      # Get option expiration chain for a symbol.
      # @param symbol [String] The symbol for which to get option expiration dates.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed
      path = "/marketdata/v1/expirationchain"
      response = get(path, { symbol: symbol })

      if return_data_objects
        expiration_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::OptionExpirationChain.build(expiration_data)
      else
        response
      end
    end

    def get_price_history(
      symbol,
      period_type: nil,
      period: nil,
      frequency_type: nil,
      frequency: nil,
      start_datetime: nil,
      end_datetime: nil,
      need_extended_hours_data: nil,
      need_previous_close: nil,
      return_data_objects: true
    )
      # Get price history for a symbol.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      period_type = convert_enum(period_type, SchwabRb::PriceHistory::PeriodTypes) if period_type
      period = convert_enum(period, SchwabRb::PriceHistory::Periods) if period
      frequency_type = convert_enum(frequency_type, SchwabRb::PriceHistory::FrequencyTypes) if frequency_type
      frequency = convert_enum(frequency, SchwabRb::PriceHistory::Frequencies) if frequency

      params = { "symbol" => symbol }

      params["periodType"] = period_type if period_type
      params["period"] = period if period
      params["frequencyType"] = frequency_type if frequency_type
      params["frequency"] = frequency if frequency
      params["startDate"] = format_date_as_millis("start_datetime", start_datetime) if start_datetime
      params["endDate"] = format_date_as_millis("end_datetime", end_datetime) if end_datetime
      params["needExtendedHoursData"] = need_extended_hours_data unless need_extended_hours_data.nil?
      params["needPreviousClose"] = need_previous_close unless need_previous_close.nil?
      path = "/marketdata/v1/pricehistory"

      response = get(path, params)

      if return_data_objects
        price_history_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::PriceHistory.build(price_history_data)
      else
        response
      end
    end

    def get_price_history_every_minute(symbol,
                                       start_datetime: nil,
                                       end_datetime: nil,
                                       need_extended_hours_data: nil,
                                       need_previous_close: nil)
      refresh_token_if_needed

      start_datetime, end_datetime = normalize_start_and_end_datetimes(
        start_datetime, end_datetime
      )

      get_price_history(
        symbol,
        period_type: SchwabRb::PriceHistory::PeriodType::DAY,
        period: SchwabRb::PriceHistory::Period::ONE_DAY,
        frequency_type: SchwabRb::PriceHistory::FrequencyType::MINUTE,
        frequency: SchwabRb::PriceHistory::Frequency::EVERY_MINUTE,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        need_extended_hours_data: need_extended_hours_data,
        need_previous_close: need_previous_close
      )
    end

    def get_price_history_every_five_minutes(symbol,
                                             start_datetime: nil,
                                             end_datetime: nil,
                                             need_extended_hours_data: nil,
                                             need_previous_close: nil)
      refresh_token_if_needed

      start_datetime, end_datetime = normalize_start_and_end_datetimes(
        start_datetime, end_datetime
      )

      get_price_history(
        symbol,
        period_type: SchwabRb::PriceHistory::PeriodType::DAY,
        period: SchwabRb::PriceHistory::Period::ONE_DAY,
        frequency_type: SchwabRb::PriceHistory::FrequencyType::MINUTE,
        frequency: SchwabRb::PriceHistory::Frequency::EVERY_FIVE_MINUTES,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        need_extended_hours_data: need_extended_hours_data,
        need_previous_close: need_previous_close
      )
    end

    def get_price_history_every_ten_minutes(symbol,
                                            start_datetime: nil,
                                            end_datetime: nil,
                                            need_extended_hours_data: nil,
                                            need_previous_close: nil)
      refresh_token_if_needed

      start_datetime, end_datetime = normalize_start_and_end_datetimes(
        start_datetime, end_datetime
      )

      get_price_history(
        symbol,
        period_type: SchwabRb::PriceHistory::PeriodType::DAY,
        period: SchwabRb::PriceHistory::Period::ONE_DAY,
        frequency_type: SchwabRb::PriceHistory::FrequencyType::MINUTE,
        frequency: SchwabRb::PriceHistory::Frequency::EVERY_TEN_MINUTES,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        need_extended_hours_data: need_extended_hours_data,
        need_previous_close: need_previous_close
      )
    end

    def get_price_history_every_fifteen_minutes(symbol,
                                                start_datetime: nil,
                                                end_datetime: nil,
                                                need_extended_hours_data: nil,
                                                need_previous_close: nil)
      refresh_token_if_needed

      start_datetime, end_datetime = normalize_start_and_end_datetimes(
        start_datetime, end_datetime
      )

      get_price_history(
        symbol,
        period_type: SchwabRb::PriceHistory::PeriodType::DAY,
        period: SchwabRb::PriceHistory::Period::ONE_DAY,
        frequency_type: SchwabRb::PriceHistory::FrequencyType::MINUTE,
        frequency: SchwabRb::PriceHistory::Frequency::EVERY_FIFTEEN_MINUTES,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        need_extended_hours_data: need_extended_hours_data,
        need_previous_close: need_previous_close
      )
    end

    def get_price_history_every_thirty_minutes(symbol,
                                               start_datetime: nil,
                                               end_datetime: nil,
                                               need_extended_hours_data: nil,
                                               need_previous_close: nil)
      refresh_token_if_needed

      start_datetime, end_datetime = normalize_start_and_end_datetimes(
        start_datetime, end_datetime
      )

      get_price_history(
        symbol,
        period_type: SchwabRb::PriceHistory::PeriodType::DAY,
        period: SchwabRb::PriceHistory::Period::ONE_DAY,
        frequency_type: SchwabRb::PriceHistory::FrequencyType::MINUTE,
        frequency: SchwabRb::PriceHistory::Frequency::EVERY_THIRTY_MINUTES,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        need_extended_hours_data: need_extended_hours_data,
        need_previous_close: need_previous_close
      )
    end

    def get_price_history_every_day(symbol,
                                    start_datetime: nil,
                                    end_datetime: nil,
                                    need_extended_hours_data: nil,
                                    need_previous_close: nil)
      refresh_token_if_needed

      start_datetime, end_datetime = normalize_start_and_end_datetimes(
        start_datetime, end_datetime
      )

      get_price_history(
        symbol,
        period_type: SchwabRb::PriceHistory::PeriodType::YEAR,
        period: SchwabRb::PriceHistory::Period::TWENTY_YEARS,
        frequency_type: SchwabRb::PriceHistory::FrequencyType::DAILY,
        frequency: SchwabRb::PriceHistory::Frequency::EVERY_MINUTE,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        need_extended_hours_data: need_extended_hours_data,
        need_previous_close: need_previous_close
      )
    end

    def get_price_history_every_week(symbol,
                                     start_datetime: nil,
                                     end_datetime: nil,
                                     need_extended_hours_data: nil,
                                     need_previous_close: nil)
      refresh_token_if_needed

      start_datetime, end_datetime = normalize_start_and_end_datetimes(
        start_datetime, end_datetime
      )

      get_price_history(
        symbol,
        period_type: SchwabRb::PriceHistory::PeriodType::YEAR,
        period: SchwabRb::PriceHistory::Period::TWENTY_YEARS,
        frequency_type: SchwabRb::PriceHistory::FrequencyType::WEEKLY,
        frequency: SchwabRb::PriceHistory::Frequency::EVERY_MINUTE,
        start_datetime: start_datetime,
        end_datetime: end_datetime,
        need_extended_hours_data: need_extended_hours_data,
        need_previous_close: need_previous_close
      )
    end

    def get_movers(index, sort_order: nil, frequency: nil, return_data_objects: true)
      # Get a list of the top ten movers for a given index.
      #
      # @param index [String] Category of mover. See Movers::Index for valid values.
      # @param sort_order [String] Order in which to return values. See Movers::SortOrder for valid values.
      # @param frequency [String] Only return movers that saw this magnitude or greater.
      #   See Movers::Frequency for valid values.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      index = convert_enum(index, SchwabRb::Movers::Indexes)
      sort_order = convert_enum(sort_order, SchwabRb::Movers::SortOrders) if sort_order
      frequency = convert_enum(frequency, SchwabRb::Movers::Frequencies) if frequency

      path = "/marketdata/v1/movers/#{index}"

      params = {}
      params["sort"] = sort_order if sort_order
      params["frequency"] = frequency.to_s if frequency

      response = get(path, params)

      if return_data_objects
        movers_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::MarketMoversFactory.build(movers_data)
      else
        response
      end
    end

    def get_market_hours(markets, date: nil, return_data_objects: true)
      # Retrieve market hours for specified markets.
      #
      # @param markets [Array, String] Markets for which to return trading hours.
      # @param date [Date] Date for which to return market hours. Accepts values up to
      #                    one year from today.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      markets = convert_enum_iterable(markets, SchwabRb::MarketHours::Markets)

      params = { "markets" => markets.join(",") }
      params["date"] = format_date_as_day("date", date) if date

      response = get("/marketdata/v1/markets", params)

      if return_data_objects
        market_hours_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::MarketHours.build(market_hours_data)
      else
        response
      end
    end

    def get_instruments(symbols, projection, return_data_objects: true)
      # Get instrument details by using different search methods. Also used
      # to get fundamental instrument data using the "FUNDAMENTAL" projection.
      #
      # @param symbols [String, Array] For "FUNDAMENTAL" projection, the symbols to fetch.
      #                                For other projections, a search term.
      # @param projection [String] Search mode or "FUNDAMENTAL" for instrument fundamentals.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      symbols = [symbols] unless symbols.is_a?(Array)
      projection = convert_enum(projection, SchwabRb::Orders::Instrument::Projections)
      params = {
        "symbol" => symbols.join(","),
        "projection" => projection
      }

      response = get("/marketdata/v1/instruments", params)

      if return_data_objects
        instruments_data = JSON.parse(response.body, symbolize_names: true)
        instruments_data.map do |instrument_data|
          SchwabRb::DataObjects::Instrument.build(instrument_data)
        end
      else
        response
      end
    end

    def get_instrument_by_cusip(cusip, return_data_objects: true)
      # Get instrument information for a single instrument by CUSIP.
      #
      # @param cusip [String] CUSIP of the instrument to fetch. Leading zeroes must be preserved.
      # @param return_data_objects [Boolean] Whether to return data objects or raw JSON
      refresh_token_if_needed

      raise ArgumentError, "cusip must be passed as a string" unless cusip.is_a?(String)

      response = get("/marketdata/v1/instruments/#{cusip}", {})

      if return_data_objects
        instrument_data = JSON.parse(response.body, symbolize_names: true)
        SchwabRb::DataObjects::Instrument.build(instrument_data)
      else
        response
      end
    end

    private

    def make_order_query(
      max_results: nil,
      from_entered_datetime: nil,
      to_entered_datetime: nil,
      status: nil
    )
      status = convert_enum(status, SchwabRb::Order::Statuses) if status

      from_entered_datetime ||= (DateTime.now.new_offset(0) - 60) # 60 days ago (UTC)
      to_entered_datetime ||= DateTime.now.new_offset(0)          # Current UTC time

      params = {
        "fromEnteredTime" => format_date_as_iso("from_entered_datetime", from_entered_datetime),
        "toEnteredTime" => format_date_as_iso("to_entered_datetime", to_entered_datetime)
      }

      params["maxResults"] = max_results if max_results
      params["status"] = status if status

      params
    end

    def format_date_as_iso(var_name, dt)
      assert_type(var_name, dt, [Date, DateTime])
      dt = DateTime.new(dt.year, dt.month, dt.day) unless dt.is_a?(DateTime)
      dt.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
    end

    def format_date_as_day(var_name, date)
      assert_type(var_name, date, [Date, DateTime])
      date = Date.new(date.year, date.month, date.day) unless date.is_a?(Date)
      date.strftime("%Y-%m-%d")
    end

    def format_date_as_millis(var_name, dt)
      assert_type(var_name, dt, [Date, DateTime])
      dt = DateTime.new(dt.year, dt.month, dt.day) unless dt.is_a?(DateTime)
      (dt.to_time.to_f * 1000).to_i
    end

    def normalize_start_and_end_datetimes(start_datetime, end_datetime)
      start_datetime ||= DateTime.new(1971, 1, 1)
      end_datetime ||= DateTime.now + 7

      [start_datetime, end_datetime]
    end

    def authorize_request(request)
      request["Authorization"] = "Bearer #{@session.token}"
      request
    end

    def refresh_token_if_needed
      return unless session.expired?

      new_session = token_manager.refresh_token(self)
      @session = new_session
    end

    def assert_type(var_name, value, types)
      return if types.any? { |type| value.is_a?(type) }

      raise ArgumentError, "#{var_name} must be one of #{types.join(', ')}"
    end
  end
end
