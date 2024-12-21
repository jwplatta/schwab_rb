module SchwabRb
  module Orders
    class Instrument
      module Projection
        SYMBOL_SEARCH = 'symbol-search'
        SYMBOL_REGEX = 'symbol-regex'
        DESCRIPTION_SEARCH = 'desc-search'
        DESCRIPTION_REGEX = 'desc-regex'
        SEARCH = 'search'
        FUNDAMENTAL = 'fundamental'
      end

      def self.projections
        Projection.constants.map { |const| Projection.const_get(const) }
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
        super('EQUITY', symbol)
      end
    end

    class OptionInstrument < BaseInstrument
      def initialize(symbol)
        super('OPTION', symbol)
      end
    end
  end
end
