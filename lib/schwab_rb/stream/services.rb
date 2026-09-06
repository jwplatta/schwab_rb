# frozen_string_literal: true

module SchwabRb
  module Stream
    module Services
      LEVELONE_EQUITIES = "LEVELONE_EQUITIES"
      LEVELONE_OPTIONS = "LEVELONE_OPTIONS"
      LEVELONE_FUTURES = "LEVELONE_FUTURES"
      LEVELONE_FUTURES_OPTIONS = "LEVELONE_FUTURES_OPTIONS"
      LEVELONE_FOREX = "LEVELONE_FOREX"
      NYSE_BOOK = "NYSE_BOOK"
      NASDAQ_BOOK = "NASDAQ_BOOK"
      OPTIONS_BOOK = "OPTIONS_BOOK"
      CHART_EQUITY = "CHART_EQUITY"
      CHART_FUTURES = "CHART_FUTURES"
      SCREENER_EQUITY = "SCREENER_EQUITY"
      SCREENER_OPTION = "SCREENER_OPTION"
      ACCT_ACTIVITY = "ACCT_ACTIVITY"

      ALL = constants.map { |c| const_get(c) }.freeze

      SYMBOL_TO_SERVICE = {
        level_one_equities: LEVELONE_EQUITIES,
        level_one_options: LEVELONE_OPTIONS,
        level_one_futures: LEVELONE_FUTURES,
        level_one_futures_options: LEVELONE_FUTURES_OPTIONS,
        level_one_forex: LEVELONE_FOREX,
        nyse_book: NYSE_BOOK,
        nasdaq_book: NASDAQ_BOOK,
        options_book: OPTIONS_BOOK,
        chart_equity: CHART_EQUITY,
        chart_futures: CHART_FUTURES,
        screener_equity: SCREENER_EQUITY,
        screener_option: SCREENER_OPTION,
        acct_activity: ACCT_ACTIVITY
      }.freeze

      def self.lookup(symbol)
        SYMBOL_TO_SERVICE[symbol] || raise(ArgumentError, "Unknown service: #{symbol.inspect}")
      end
    end

    module Commands
      LOGIN = "LOGIN"
      LOGOUT = "LOGOUT"
      SUBS = "SUBS"
      ADD = "ADD"
      UNSUBS = "UNSUBS"
      VIEW = "VIEW"
    end
  end
end
