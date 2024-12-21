module SchwabRb
  class Movers
    module Index
      DJI = '$DJI'
      COMPX = '$COMPX'
      SPX = '$SPX'
      NYSE = 'NYSE'
      NASDAQ = 'NASDAQ'
      OTCBB = 'OTCBB'
      INDEX_ALL = 'INDEX_ALL'
      EQUITY_ALL = 'EQUITY_ALL'
      OPTION_ALL = 'OPTION_ALL'
      OPTION_PUT = 'OPTION_PUT'
      OPTION_CALL = 'OPTION_CALL'
    end

    module SortOrder
      VOLUME = 'VOLUME'
      TRADES = 'TRADES'
      PERCENT_CHANGE_UP = 'PERCENT_CHANGE_UP'
      PERCENT_CHANGE_DOWN = 'PERCENT_CHANGE_DOWN'
    end

    module Frequency
      ZERO = 0
      ONE = 1
      FIVE = 5
      TEN = 10
      THIRTY = 30
      SIXTY = 60
    end

    def self.indexes
      Index.constants.map { |const| Index.const_get(const) }
    end

    def self.sort_orders
      SortOrder.constants.map { |const| SortOrder.const_get(const) }
    end

    def self.frequencies
      Frequency.constants.map { |const| Frequency.const_get
  end
end