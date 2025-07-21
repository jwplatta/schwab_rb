# frozen_string_literal: true

module SchwabRb
  module DataObjects
    class MarketMoversFactory
      def self.build(movers_data)
        screeners = movers_data[:screeners] || []
        movers = screeners.map { |screener| Mover.new(screener) }
        MarketMovers.new(movers)
      end
    end

    class MarketMovers
      attr_reader :movers

      def initialize(movers)
        @movers = movers
      end

      def count
        @movers.size
      end

      def symbols
        @movers.map(&:symbol)
      end

      def find_by_symbol(symbol)
        @movers.find { |mover| mover.symbol == symbol }
      end

      def top(num = 5)
        @movers.first(num)
      end

      def each(&block)
        @movers.each(&block)
      end

      def to_a
        @movers
      end
    end

    class Mover
      attr_reader :description, :volume, :last_price, :net_change, :market_share,
                  :total_volume, :trades, :net_percent_change, :symbol

      def initialize(data)
        @description = data[:description]
        @volume = data[:volume]
        @last_price = data[:lastPrice]
        @net_change = data[:netChange]
        @market_share = data[:marketShare]
        @total_volume = data[:totalVolume]
        @trades = data[:trades]
        @net_percent_change = data[:netPercentChange]
        @symbol = data[:symbol]
      end

      def percentage_of_total_volume
        return 0.0 if @total_volume.nil? || @total_volume.zero?

        (@volume / @total_volume.to_f) * 100.0
      end

      def positive_change?
        @net_change&.positive?
      end

      def negative_change?
        @net_change&.negative?
      end

      def net_change_percentage
        (@net_percent_change * 100).round(2) if @net_percent_change
      end

      def to_h
        {
          symbol: @symbol,
          description: @description,
          volume: @volume,
          last_price: @last_price,
          net_change: @net_change,
          market_share: @market_share,
          total_volume: @total_volume,
          trades: @trades,
          net_percent_change: @net_percent_change
        }
      end

      def to_s
        "<Mover symbol: #{@symbol}, volume: #{@volume}, last_price: #{@last_price}, net_change: #{@net_change}>"
      end
    end
  end
end
