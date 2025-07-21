module SchwabRb
  module Orders
    class Instrument
      module Projections
        SYMBOL_SEARCH = "symbol-search"
        SYMBOL_REGEX = "symbol-regex"
        DESCRIPTION_SEARCH = "desc-search"
        DESCRIPTION_REGEX = "desc-regex"
        SEARCH = "search"
        FUNDAMENTAL = "fundamental"
      end
    end

    class BaseInstrument
      def initialize(asset_type, symbol)
        @asset_type = asset_type
        @symbol = symbol
      end

      attr_reader :asset_type, :symbol
    end

    class EquityInstrument < BaseInstrument
      def initialize(symbol)
        super("EQUITY", symbol)
      end
    end

    class OptionInstrument < BaseInstrument
      def initialize(symbol)
        super("OPTION", symbol)
      end
    end
  end
end
