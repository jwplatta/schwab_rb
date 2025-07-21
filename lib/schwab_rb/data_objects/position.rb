# frozen_string_literal: true

require_relative "instrument"

module SchwabRb
  module DataObjects
    class Position
      attr_reader :short_quantity, :average_price, :current_day_profit_loss, :current_day_profit_loss_percentage,
                  :long_quantity, :settled_long_quantity, :settled_short_quantity, :instrument, :market_value,
                  :maintenance_requirement, :average_long_price, :average_short_price, :long_open_profit_loss, :short_open_profit_loss, :current_day_cost, :strike, :delta, :mark

      class << self
        def build(data)
          new(
            short_quantity: data[:shortQuantity],
            average_price: data[:averagePrice],
            current_day_profit_loss: data[:currentDayProfitLoss],
            current_day_profit_loss_percentage: data[:currentDayProfitLossPercentage],
            long_quantity: data[:longQuantity],
            settled_long_quantity: data[:settledLongQuantity],
            settled_short_quantity: data[:settledShortQuantity],
            instrument: Instrument.build(data[:instrument]),
            market_value: data[:marketValue],
            maintenance_requirement: data[:maintenanceRequirement],
            average_long_price: data[:averageLongPrice],
            average_short_price: data[:averageShortPrice],
            long_open_profit_loss: data[:longOpenProfitLoss],
            short_open_profit_loss: data[:shortOpenProfitLoss],
            current_day_cost: data[:currentDayCost]
          )
        end
      end

      def initialize(
        short_quantity: nil, average_price: nil, current_day_profit_loss: nil, current_day_profit_loss_percentage: nil,
        long_quantity: nil, settled_long_quantity: nil, settled_short_quantity: nil, instrument: nil, market_value: nil, maintenance_requirement: nil, average_long_price: nil, average_short_price: nil, long_open_profit_loss: nil, short_open_profit_loss: nil, current_day_cost: nil, strike: nil, delta: nil, mark: nil
      )
        @short_quantity = short_quantity
        @average_price = average_price
        @current_day_profit_loss = current_day_profit_loss
        @current_day_profit_loss_percentage = current_day_profit_loss_percentage
        @long_quantity = long_quantity
        @settled_long_quantity = settled_long_quantity
        @settled_short_quantity = settled_short_quantity
        @instrument = instrument
        @market_value = market_value
        @maintenance_requirement = maintenance_requirement
        @average_long_price = average_long_price
        @average_short_price = average_short_price
        @long_open_profit_loss = long_open_profit_loss
        @short_open_profit_loss = short_open_profit_loss
        @current_day_cost = current_day_cost
        @strike = strike
        @delta = delta
        @mark = mark
      end

      def symbol
        instrument&.symbol
      end

      def underlying_symbol
        instrument.underlying_symbol
      end

      def long?
        long_quantity.positive?
      end

      def short?
        short_quantity.positive?
      end

      def long_short
        if long?
          "LONG"
        elsif short?
          "SHORT"
        else
          "NONE"
        end
      end

      def put_call
        instrument.put_call
      end

      def to_h
        {
          symbol: symbol,
          underlying_symbol: underlying_symbol,
          average_price: average_price,
          market_value: market_value,
          put_call: put_call,
          long_short: long_short
        }
      end
    end
  end
end
