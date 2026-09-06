# frozen_string_literal: true

module SchwabRb
  module Stream
    module Fields
      module LevelOneEquity
        SYMBOL = 0
        BID_PRICE = 1
        ASK_PRICE = 2
        LAST_PRICE = 3
        BID_SIZE = 4
        ASK_SIZE = 5
        ASK_ID = 6
        BID_ID = 7
        TOTAL_VOLUME = 8
        LAST_SIZE = 9
        HIGH_PRICE = 10
        LOW_PRICE = 11
        CLOSE_PRICE = 12
        EXCHANGE_ID = 13
        MARGINABLE = 14
        DESCRIPTION = 15
        LAST_ID = 16
        OPEN_PRICE = 17
        NET_CHANGE = 18
        HIGH_PRICE_52_WEEK = 19
        LOW_PRICE_52_WEEK = 20
        PE_RATIO = 21
        DIVIDEND_AMOUNT = 22
        DIVIDEND_YIELD = 23
        NAV = 24
        EXCHANGE_NAME = 25
        DIVIDEND_DATE = 26
        REGULAR_MARKET_QUOTE = 27
        REGULAR_MARKET_TRADE = 28
        REGULAR_MARKET_LAST_PRICE = 29
        REGULAR_MARKET_LAST_SIZE = 30
        REGULAR_MARKET_NET_CHANGE = 31
        SECURITY_STATUS = 32
        MARK = 33
        QUOTE_TIME_MILLIS = 34
        TRADE_TIME_MILLIS = 35
        REGULAR_MARKET_TRADE_MILLIS = 36
        BID_TIME_MILLIS = 37
        ASK_TIME_MILLIS = 38
        ASK_MIC_ID = 39
        BID_MIC_ID = 40
        LAST_MIC_ID = 41
        NET_CHANGE_PERCENT = 42
        REGULAR_MARKET_CHANGE_PERCENT = 43
        MARK_CHANGE = 44
        MARK_CHANGE_PERCENT = 45
        HTB_QUANTITY = 46
        HTB_RATE = 47
        HARD_TO_BORROW = 48
        IS_SHORTABLE = 49
        POST_MARKET_NET_CHANGE = 50
        POST_MARKET_NET_CHANGE_PERCENT = 51

        ALL = (0..51).to_a.freeze
      end

      module LevelOneOption
        SYMBOL = 0
        DESCRIPTION = 1
        BID_PRICE = 2
        ASK_PRICE = 3
        LAST_PRICE = 4
        HIGH_PRICE = 5
        LOW_PRICE = 6
        CLOSE_PRICE = 7
        TOTAL_VOLUME = 8
        OPEN_INTEREST = 9
        VOLATILITY = 10
        MONEY_INTRINSIC_VALUE = 11
        EXPIRATION_YEAR = 12
        MULTIPLIER = 13
        DIGITS = 14
        OPEN_PRICE = 15
        BID_SIZE = 16
        ASK_SIZE = 17
        LAST_SIZE = 18
        NET_CHANGE = 19
        STRIKE_TYPE = 20
        CONTRACT_TYPE = 21
        UNDERLYING = 22
        EXPIRATION_MONTH = 23
        DELIVERABLES = 24
        TIME_VALUE = 25
        EXPIRATION_DAY = 26
        DAYS_TO_EXPIRATION = 27
        DELTA = 28
        GAMMA = 29
        THETA = 30
        VEGA = 31
        RHO = 32
        SECURITY_STATUS = 33
        THEORETICAL_OPTION_VALUE = 34
        UNDERLYING_PRICE = 35
        UV_EXPIRATION_TYPE = 36
        MARK = 37
        QUOTE_TIME_MILLIS = 38
        TRADE_TIME_MILLIS = 39
        EXCHANGE_ID = 40
        EXCHANGE_NAME = 41
        LAST_TRADING_DAY = 42
        SETTLEMENT_TYPE = 43
        NET_PERCENT_CHANGE = 44
        MARK_CHANGE = 45
        MARK_CHANGE_PERCENT = 46
        IMPLIED_YIELD = 47
        IS_PENNY = 48
        OPTION_ROOT = 49
        HIGH_PRICE_52_WEEK = 50
        LOW_PRICE_52_WEEK = 51
        INDICATIVE_ASKING_PRICE = 52
        INDICATIVE_BID_PRICE = 53
        INDICATIVE_QUOTE_TIME = 54
        EXERCISE_TYPE = 55

        ALL = (0..55).to_a.freeze
      end

      module LevelOneFutures
        SYMBOL = 0
        BID_PRICE = 1
        ASK_PRICE = 2
        LAST_PRICE = 3
        BID_SIZE = 4
        ASK_SIZE = 5
        ASK_ID = 6
        BID_ID = 7
        TOTAL_VOLUME = 8
        LAST_SIZE = 9
        QUOTE_TIME_MILLIS = 10
        TRADE_TIME_MILLIS = 11
        HIGH_PRICE = 12
        LOW_PRICE = 13
        CLOSE_PRICE = 14
        EXCHANGE_ID = 15
        DESCRIPTION = 16
        LAST_ID = 17
        OPEN_PRICE = 18
        NET_CHANGE = 19
        FUTURE_PERCENT_CHANGE = 20
        EXCHANGE_NAME = 21
        SECURITY_STATUS = 22
        OPEN_INTEREST = 23
        MARK = 24
        TICK = 25
        TICK_AMOUNT = 26
        PRODUCT = 27
        FUTURE_PRICE_FORMAT = 28
        FUTURE_TRADING_HOURS = 29
        FUTURE_IS_TRADABLE = 30
        FUTURE_MULTIPLIER = 31
        FUTURE_IS_ACTIVE = 32
        FUTURE_SETTLEMENT_PRICE = 33
        FUTURE_ACTIVE_SYMBOL = 34
        FUTURE_EXPIRATION_DATE = 35
        EXPIRATION_STYLE = 36
        ASK_MIC_ID = 37
        BID_MIC_ID = 38
        LAST_MIC_ID = 39
        SETTLEMENT_DATE = 40

        ALL = (0..40).to_a.freeze
      end

      module LevelOneFuturesOptions
        SYMBOL = 0
        BID_PRICE = 1
        ASK_PRICE = 2
        LAST_PRICE = 3
        BID_SIZE = 4
        ASK_SIZE = 5
        BID_ID = 6
        ASK_ID = 7
        TOTAL_VOLUME = 8
        LAST_SIZE = 9
        QUOTE_TIME_MILLIS = 10
        TRADE_TIME_MILLIS = 11
        HIGH_PRICE = 12
        LOW_PRICE = 13
        CLOSE_PRICE = 14
        LAST_ID = 15
        DESCRIPTION = 16
        OPEN_PRICE = 17
        OPEN_INTEREST = 18
        MARK = 19
        TICK = 20
        TICK_AMOUNT = 21
        FUTURE_MULTIPLIER = 22
        FUTURE_SETTLEMENT_PRICE = 23
        UNDERLYING_SYMBOL = 24
        STRIKE_PRICE = 25
        FUTURE_EXPIRATION_DATE = 26
        EXPIRATION_STYLE = 27
        CONTRACT_TYPE = 28
        SECURITY_STATUS = 29
        EXCHANGE_ID = 30
        EXCHANGE_NAME = 31

        ALL = (0..31).to_a.freeze
      end

      module LevelOneForex
        SYMBOL = 0
        BID_PRICE = 1
        ASK_PRICE = 2
        LAST_PRICE = 3
        BID_SIZE = 4
        ASK_SIZE = 5
        TOTAL_VOLUME = 6
        LAST_SIZE = 7
        QUOTE_TIME_MILLIS = 8
        TRADE_TIME_MILLIS = 9
        HIGH_PRICE = 10
        LOW_PRICE = 11
        CLOSE_PRICE = 12
        EXCHANGE_ID = 13
        DESCRIPTION = 14
        OPEN_PRICE = 15
        NET_CHANGE = 16
        CHANGE_PERCENT = 17
        EXCHANGE_NAME = 18
        DIGITS = 19
        SECURITY_STATUS = 20
        TICK = 21
        TICK_AMOUNT = 22
        PRODUCT = 23
        TRADING_HOURS = 24
        IS_TRADABLE = 25
        MARKET_MAKER = 26
        HIGH_PRICE_52_WEEK = 27
        LOW_PRICE_52_WEEK = 28
        MARK = 29

        ALL = (0..29).to_a.freeze
      end

      module Book
        SYMBOL = 0
        BOOK_TIME = 1
        BIDS = 2
        ASKS = 3

        ALL = (0..3).to_a.freeze
      end

      module BookBid
        BID_PRICE = 0
        TOTAL_VOLUME = 1
        NUM_BIDS = 2
        BIDS = 3
      end

      module BookAsk
        ASK_PRICE = 0
        TOTAL_VOLUME = 1
        NUM_ASKS = 2
        ASKS = 3
      end

      module BookExchange
        EXCHANGE = 0
        VOLUME = 1
        SEQUENCE = 2
      end

      module ChartEquity
        SYMBOL = 0
        SEQUENCE = 1
        OPEN_PRICE = 2
        HIGH_PRICE = 3
        LOW_PRICE = 4
        CLOSE_PRICE = 5
        VOLUME = 6
        CHART_TIME_MILLIS = 7
        CHART_DAY = 8

        ALL = (0..8).to_a.freeze
      end

      module ChartFutures
        SYMBOL = 0
        CHART_TIME_MILLIS = 1
        OPEN_PRICE = 2
        HIGH_PRICE = 3
        LOW_PRICE = 4
        CLOSE_PRICE = 5
        VOLUME = 6

        ALL = (0..6).to_a.freeze
      end

      module Screener
        SYMBOL = 0
        TIMESTAMP = 1
        SORT_FIELD = 2
        FREQUENCY = 3
        ITEMS = 4

        ALL = (0..4).to_a.freeze
      end

      module AccountActivity
        SUBSCRIPTION_KEY = 0
        ACCOUNT = 1
        MESSAGE_TYPE = 2
        MESSAGE_DATA = 3

        ALL = (0..3).to_a.freeze
      end

      SERVICE_FIELDS = {
        "LEVELONE_EQUITIES" => LevelOneEquity,
        "LEVELONE_OPTIONS" => LevelOneOption,
        "LEVELONE_FUTURES" => LevelOneFutures,
        "LEVELONE_FUTURES_OPTIONS" => LevelOneFuturesOptions,
        "LEVELONE_FOREX" => LevelOneForex,
        "NYSE_BOOK" => Book,
        "NASDAQ_BOOK" => Book,
        "OPTIONS_BOOK" => Book,
        "CHART_EQUITY" => ChartEquity,
        "CHART_FUTURES" => ChartFutures,
        "SCREENER_EQUITY" => Screener,
        "SCREENER_OPTION" => Screener,
        "ACCT_ACTIVITY" => AccountActivity
      }.freeze

      def self.resolve(service, fields)
        return SERVICE_FIELDS[service]::ALL if fields == :all

        Array(fields).map(&:to_i)
      end
    end
  end
end
