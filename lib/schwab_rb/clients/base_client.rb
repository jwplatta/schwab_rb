require "date"
require_relative "../utils/enum_enforcer"

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

    def get_account(account_hash, fields: nil)
      # Account balances, positions, and orders for a given account hash.
      #
      # @param fields [Array] Balances displayed by default, additional fields can be
      # added here by adding values from Account.fields.
      refresh_token_if_needed

      fields = convert_enum_iterable(fields, SchwabRb::Account::Statuses) if fields

      params = {}
      params[:fields] = fields.join(",") if fields

      path = "/trader/v1/accounts/#{account_hash}"
      get(path, params)
    end

    def get_accounts(fields: nil)
      # Account balances, positions, and orders for all linked accounts.
      #
      # Note: This method does not return account hashes.
      #
      # @param fields [Array] Balances displayed by default, additional fields can be
      # added here by adding values from Account.fields.
      refresh_token_if_needed

      fields = convert_enum_iterable(fields, SchwabRb::Account::Statuses) if fields

      params = {}
      params[:fields] = fields.join(",") if fields

      path = "/trader/v1/accounts"
      get(path, params)
    end

    def get_account_numbers
      # Returns a mapping from account IDs available to this token to the
      # account hash that should be passed whenever referring to that account
      # in API calls.
      refresh_token_if_needed

      path = "/trader/v1/accounts/accountNumbers"
      get(path, {})
    end

    def get_order(order_id, account_hash)
      # Get a specific order for a specific account by its order ID.
      #
      # @param order_id [String] The order ID.
      # @param account_hash [String] The account hash.

      path = "/trader/v1/accounts/#{account_hash}/orders/#{order_id}"
      get(path, {})
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
      status: nil
    )
      # Orders for a specific account. Optionally specify a single status on which to filter.
      #
      # @param max_results [Integer] The maximum number of orders to retrieve.
      # @param from_entered_datetime [DateTime] Start of the query date range (default: 60 days ago).
      # @param to_entered_datetime [DateTime] End of the query date range (default: now).
      # @param status [String] Restrict query to orders with this status.
      refresh_token_if_needed

      if from_entered_datetime.nil?
        from_entered_datetime = DateTime.now.new_offset(0) - 60
      end

      if to_entered_datetime.nil?
        to_entered_datetime = DateTime.now
      end

      path = "/trader/v1/accounts/#{account_hash}/orders"
      params = make_order_query(
        max_results: max_results,
        from_entered_datetime: from_entered_datetime,
        to_entered_datetime: to_entered_datetime,
        status: status
      )

      get(path, params)
    end

    def get_all_linked_account_orders(
      max_results: nil,
      from_entered_datetime: nil,
      to_entered_datetime: nil,
      status: nil
    )
      # Orders for all linked accounts. Optionally specify a single status on which to filter.
      #
      # @param max_results [Integer] The maximum number of orders to retrieve.
      # @param from_entered_datetime [DateTime] Start of the query date range (default: 60 days ago).
      # @param to_entered_datetime [DateTime] End of the query date range (default: now).
      # @param status [String] Restrict query to orders with this status.
      refresh_token_if_needed

      path = "/trader/v1/orders"
      params = make_order_query(
        max_results: max_results,
        from_entered_datetime: from_entered_datetime,
        to_entered_datetime: to_entered_datetime,
        status: status
      )

      get(path, params)
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

    def preview_order(account_hash, order_spec)
      # Preview an order, i.e., test whether an order would be accepted by the
      # API and see the structure it would result in.
      refresh_token_if_needed

      order_spec = order_spec.build if order_spec.is_a?(SchwabRb::Orders::Builder)

      path = "/trader/v1/accounts/#{account_hash}/previewOrder"
      post(path, order_spec)
    end

    def get_transactions(
      account_hash,
      start_date: nil,
      end_date: nil,
      transaction_types: nil,
      symbol: nil
    )
      # Transactions for a specific account.
      #
      # @param account_hash [String] Account hash corresponding to the account.
      # @param start_date [Date, DateTime] Start date for transactions (default: 60 days ago).
      # @param end_date [Date, DateTime] End date for transactions (default: now).
      # @param transaction_types [Array] List of transaction types to filter by.
      # @param symbol [String] Filter transactions by the specified symbol.
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
      get(path, params)
    end

    def get_transaction(account_hash, order_id)
      # Transaction for a specific account.
      #
      # @param account_hash [String] Account hash corresponding to the account whose
      #                              transactions should be returned.
      # @param order_id [String] ID of the order for which to return data.
      refresh_token_if_needed

      path = "/trader/v1/accounts/#{account_hash}/transactions/#{order_id}"
      get(path, {})
    end

    def get_user_preferences
      refresh_token_if_needed
      path = "/trader/v1/userPreference"
      get(path, {})
    end

    def get_quote(symbol, fields: nil)
      # Get quote for a symbol.
      #
      # @param symbol [String] Single symbol to fetch.
      # @param fields [Array] Fields to request. If unset, return all available
      #                       data (i.e., all fields). See `GetQuote::Field` for options.
      refresh_token_if_needed

      fields = convert_enum_iterable(fields, SchwabRb::Quote::Types) if fields
      params = fields ? { "fields" => fields.join(",") } : {}
      path = "/marketdata/v1/#{symbol}/quotes"
      get(path, params)
    end

    def get_quotes(symbols, fields: nil, indicative: nil)
      # Get quotes for symbols. This method supports all symbols, including those
      # containing non-alphanumeric characters like `/ES`.
      #
      # @param symbols [Array, String] Symbols to fetch. Can be a single symbol or an array of symbols.
      # @param fields [Array] Fields to request. If unset, return all available data.
      #                       See `GetQuote::Field` for options.
      # @param indicative [Boolean] If set, fetch indicative quotes. Must be true or false.
      refresh_token_if_needed

      symbols = [symbols] if symbols.is_a?(String)
      params = { "symbols" => symbols.join(",") }
      fields = convert_enum_iterable(fields, Schwab::Quote::Types) if fields
      params["fields"] = fields.join(",") if fields

      unless indicative.nil?
        unless [true, false].include?(indicative)
          raise ArgumentError, "value of 'indicative' must be either true or false"
        end

        params["indicative"] = indicative ? "true" : "false"
      end

      path = "/marketdata/v1/quotes"
      get(path, params)
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
      entitlement: nil
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
      get(path, params)
    end

    def get_option_expiration_chain(symbol)
      refresh_token_if_needed
      path = "/marketdata/v1/expirationchain"
      get(path, { symbol: symbol })
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
      need_previous_close: nil
    )
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

      get(path, params)
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

    def get_movers(index, sort_order: nil, frequency: nil)
      # Get a list of the top ten movers for a given index.
      #
      # @param index [String] Category of mover. See Movers::Index for valid values.
      # @param sort_order [String] Order in which to return values. See Movers::SortOrder for valid values.
      # @param frequency [String] Only return movers that saw this magnitude or greater. See Movers::Frequency for valid values.
      refresh_token_if_needed

      index = convert_enum(index, SchwabRb::Movers::Indexes)
      sort_order = convert_enum(sort_order, SchwabRb::Movers::SortOrders) if sort_order
      frequency = convert_enum(frequency, SchwabRb::Movers::Frequencies) if frequency

      path = "/marketdata/v1/movers/#{index}"

      params = {}
      params["sort"] = sort_order if sort_order
      params["frequency"] = frequency.to_s if frequency

      get(path, params)
    end

    def get_market_hours(markets, date: nil)
      # Retrieve market hours for specified markets.
      #
      # @param markets [Array, String] Markets for which to return trading hours.
      # @param date [Date] Date for which to return market hours. Accepts values up to
      #                    one year from today.
      refresh_token_if_needed

      markets = convert_enum_iterable(markets, SchwabRb::MarketHours::Markets)

      params = { "markets" => markets.join(",") }
      params["date"] = format_date_as_day("date", date) if date

      get("/marketdata/v1/markets", params)
    end

    def get_instruments(symbols, projection)
      # Get instrument details by using different search methods. Also used
      # to get fundamental instrument data using the "FUNDAMENTAL" projection.
      #
      # @param symbols [String, Array] For "FUNDAMENTAL" projection, the symbols to fetch.
      #                                For other projections, a search term.
      # @param projection [String] Search mode or "FUNDAMENTAL" for instrument fundamentals.
      refresh_token_if_needed

      symbols = [symbols] unless symbols.is_a?(Array)
      projection = convert_enum(projection, SchwabRb::Orders::Instrument::Projections)
      params = {
        "symbol" => symbols.join(","),
        "projection" => projection
      }

      get("/marketdata/v1/instruments", params)
    end

    def get_instrument_by_cusip(cusip)
      # Get instrument information for a single instrument by CUSIP.
      #
      # @param cusip [String] CUSIP of the instrument to fetch. Leading zeroes must be preserved.
      refresh_token_if_needed

      raise ArgumentError, "cusip must be passed as a string" unless cusip.is_a?(String)

      get("/marketdata/v1/instruments/#{cusip}", {})
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
