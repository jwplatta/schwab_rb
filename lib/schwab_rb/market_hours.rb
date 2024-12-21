module SchwabRb
  class MarketHours
    module Market
      EQUITY = 'equity'
      OPTION = 'option'
      BOND = 'bond'
      FUTURE = 'future'
      FOREX = 'forex'
    end

    def self.markets
      Market.constants.map { |const| Market.const_get(const) }
    end
  end
end
