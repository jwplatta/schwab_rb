# frozen_string_literal: true

module SchwabRb
  module DataObjects
    class PriceHistory
      attr_reader :symbol, :empty, :candles

      class << self
        def build(data)
          new(data)
        end
      end

      def initialize(data)
        @symbol = data["symbol"]
        @empty = data["empty"]
        @candles = data["candles"]&.map { |candle_data| Candle.new(candle_data) } || []
      end

      def to_h
        {
          "symbol" => @symbol,
          "empty" => @empty,
          "candles" => @candles.map(&:to_h)
        }
      end

      def empty?
        @empty == true || @candles.empty?
      end

      def count
        @candles.length
      end
      alias size count
      alias length count

      def first_candle
        @candles.first
      end

      def last_candle
        @candles.last
      end

      def candles_for_date_range(start_date, end_date)
        start_timestamp = start_date.to_time.to_i * 1000
        end_timestamp = end_date.to_time.to_i * 1000

        @candles.select do |candle|
          candle.datetime >= start_timestamp && candle.datetime <= end_timestamp
        end
      end

      def highest_price
        return nil if @candles.empty?

        @candles.map(&:high).max
      end

      def lowest_price
        return nil if @candles.empty?

        @candles.map(&:low).min
      end

      def highest_volume
        return nil if @candles.empty?

        @candles.map(&:volume).max
      end

      def total_volume
        return 0 if @candles.empty?

        @candles.map(&:volume).sum
      end

      def average_price
        return nil if @candles.empty?

        total_price = @candles.map(&:close).sum
        total_price / @candles.length.to_f
      end

      def price_range
        return nil if @candles.empty?

        {
          high: highest_price,
          low: lowest_price,
          range: highest_price - lowest_price
        }
      end

      def each(&block)
        return enum_for(:each) unless block_given?

        @candles.each(&block)
      end

      include Enumerable

      class Candle
        attr_reader :open, :high, :low, :close, :volume, :datetime

        def initialize(data)
          @open = data["open"]
          @high = data["high"]
          @low = data["low"]
          @close = data["close"]
          @volume = data["volume"]
          @datetime = data["datetime"]
        end

        def to_h
          {
            "open" => @open,
            "high" => @high,
            "low" => @low,
            "close" => @close,
            "volume" => @volume,
            "datetime" => @datetime
          }
        end

        def date_time
          Time.at(@datetime / 1000.0) if @datetime
        end

        def date
          date_time&.to_date
        end

        def price_change
          @close - @open
        end

        def price_change_percent
          return 0 if @open == 0

          ((price_change / @open) * 100).round(4)
        end

        def is_green?
          @close > @open
        end

        def is_red?
          @close < @open
        end

        def is_doji?
          @close == @open
        end

        def body_size
          (@close - @open).abs
        end

        def wick_size
          upper_wick + lower_wick
        end

        def upper_wick
          @high - [@open, @close].max
        end

        def lower_wick
          [@open, @close].min - @low
        end

        def true_range
          [
            @high - @low,
            (@high - @close).abs,
            (@low - @close).abs
          ].max
        end

        def ohlc_average
          (@open + @high + @low + @close) / 4.0
        end

        def typical_price
          (@high + @low + @close) / 3.0
        end

        def weighted_price
          (@high + @low + @close + @close) / 4.0
        end
      end
    end
  end
end
