module SchwabRb
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
end
