# frozen_string_literal: true

module SchwabRb
  class Movers
    module Indexes
      DJI = "$DJI"
      COMPX = "$COMPX"
      SPX = "$SPX"
      NYSE = "NYSE"
      NASDAQ = "NASDAQ"
      OTCBB = "OTCBB"
      INDEX_ALL = "INDEX_ALL"
      EQUITY_ALL = "EQUITY_ALL"
      OPTION_ALL = "OPTION_ALL"
      OPTION_PUT = "OPTION_PUT"
      OPTION_CALL = "OPTION_CALL"
    end

    module SortOrders
      VOLUME = "VOLUME"
      TRADES = "TRADES"
      PERCENT_CHANGE_UP = "PERCENT_CHANGE_UP"
      PERCENT_CHANGE_DOWN = "PERCENT_CHANGE_DOWN"
    end

    module Frequencies
      ZERO = 0
      ONE = 1
      FIVE = 5
      TEN = 10
      THIRTY = 30
      SIXTY = 60
    end
  end
end
