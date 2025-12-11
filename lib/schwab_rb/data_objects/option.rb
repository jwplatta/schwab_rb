# frozen_string_literal: true

require "json"
require "date"

module SchwabRb
  module DataObjects
    class Option
      class << self
        def build(underyling_symbol, data)
          Option.new(
            symbol: data.fetch(:symbol),
            underlying_symbol: underyling_symbol,
            description: data.fetch(:description),
            strike: data.fetch(:strikePrice),
            put_call: data.fetch(:putCall),
            exchange_name: data.fetch(:exchangeName, nil),
            bid: data.fetch(:bid),
            ask: data.fetch(:ask),
            last: data.fetch(:last),
            mark: data.fetch(:mark),
            bid_size: data.fetch(:bidSize, nil),
            ask_size: data.fetch(:askSize, nil),
            bid_ask_size: data.fetch(:bidAskSize, nil),
            last_size: data.fetch(:lastSize, nil),
            high_price: data.fetch(:highPrice, nil),
            low_price: data.fetch(:lowPrice, nil),
            open_price: data.fetch(:openPrice, nil),
            close_price: data.fetch(:closePrice, nil),
            total_volume: data.fetch(:totalVolume, nil),
            trade_time_in_long: data.fetch(:tradeTimeInLong, nil),
            quote_time_in_long: data.fetch(:quoteTimeInLong, nil),
            net_change: data.fetch(:netChange, nil),
            volatility: data.fetch(:volatility, nil),
            delta: data.fetch(:delta, nil),
            gamma: data.fetch(:gamma, nil),
            theta: data.fetch(:theta, nil),
            vega: data.fetch(:vega, nil),
            rho: data.fetch(:rho, nil),
            open_interest: data.fetch(:openInterest, nil),
            time_value: data.fetch(:timeValue, nil),
            theoretical_option_value: data.fetch(:theoreticalOptionValue, nil),
            theoretical_volatility: data.fetch(:theoreticalVolatility, nil),
            option_deliverables_list: data.fetch(:optionDeliverablesList, nil),
            expiration_date: Date.parse(data.fetch(:expirationDate)),
            days_to_expiration: data.fetch(:daysToExpiration, nil),
            expiration_type: data.fetch(:expirationType, nil),
            last_trading_day: data.fetch(:lastTradingDay, nil),
            multiplier: data.fetch(:multiplier, nil),
            settlement_type: data.fetch(:settlementType, nil),
            deliverable_note: data.fetch(:deliverableNote, nil),
            percent_change: data.fetch(:percentChange, nil),
            mark_change: data.fetch(:markChange, nil),
            mark_percent_change: data.fetch(:markPercentChange, nil),
            intrinsic_value: data.fetch(:intrinsicValue, nil),
            extrinsic_value: data.fetch(:extrinsicValue, nil),
            option_root: data.fetch(:optionRoot, nil),
            exercise_type: data.fetch(:exerciseType, nil),
            high_52_week: data.fetch(:high52Week, nil),
            low_52_week: data.fetch(:low52Week, nil),
            non_standard: data.fetch(:nonStandard, nil),
            in_the_money: data.fetch(:inTheMoney, nil)
          )
        end
      end

      def initialize(
        symbol:, underlying_symbol:, description:, strike:, put_call:,
        exchange_name:, bid:, ask:, last:, mark:, bid_size:, ask_size:,
        bid_ask_size:, last_size:, high_price:, low_price:, open_price:,
        close_price:, total_volume:, trade_time_in_long:,
        quote_time_in_long:, net_change:, volatility:, delta:,
        gamma:, theta:, vega:, rho:, open_interest:, time_value:,
        theoretical_option_value:, theoretical_volatility:, option_deliverables_list:,
        expiration_date:, days_to_expiration:, expiration_type:, last_trading_day:, multiplier:,
        settlement_type:, deliverable_note:, percent_change:, mark_change:, mark_percent_change:, intrinsic_value:, extrinsic_value:, option_root:, exercise_type:, high_52_week:, low_52_week:, non_standard:, in_the_money:
      )
        @symbol = symbol
        @underlying_symbol = underlying_symbol
        @description = description
        @strike = strike
        @put_call = put_call
        @exchange_name = exchange_name
        @bid = bid
        @ask = ask
        @last = last
        @mark = mark
        @bid_size = bid_size
        @ask_size = ask_size
        @bid_ask_size = bid_ask_size
        @last_size = last_size
        @high_price = high_price
        @low_price = low_price
        @open_price = open_price
        @close_price = close_price
        @total_volume = total_volume
        @trade_time_in_long = trade_time_in_long
        @quote_time_in_long = quote_time_in_long
        @net_change = net_change
        @volatility = volatility
        @delta = delta
        @gamma = gamma
        @theta = theta
        @vega = vega
        @rho = rho
        @open_interest = open_interest
        @time_value = time_value
        @theoretical_option_value = theoretical_option_value
        @theoretical_volatility = theoretical_volatility
        @option_deliverables_list = option_deliverables_list
        @expiration_date = expiration_date
        @days_to_expiration = days_to_expiration
        @expiration_type = expiration_type
        @last_trading_day = last_trading_day
        @multiplier = multiplier
        @settlement_type = settlement_type
        @deliverable_note = deliverable_note
        @percent_change = percent_change
        @mark_change = mark_change
        @mark_percent_change = mark_percent_change
        @intrinsic_value = intrinsic_value
        @extrinsic_value = extrinsic_value
        @option_root = option_root
        @exercise_type = exercise_type
        @high_52_week = high_52_week
        @low_52_week = low_52_week
        @non_standard = non_standard
        @in_the_money = in_the_money
      end

      attr_reader :symbol, :underlying_symbol, :description, :strike, :put_call,
                  :exchange_name, :bid, :ask, :last, :mark, :bid_size, :ask_size,
                  :bid_ask_size, :last_size, :high_price, :low_price, :open_price,
                  :close_price, :total_volume, :trade_time_in_long, :quote_time_in_long,
                  :net_change, :volatility, :delta, :gamma, :theta, :vega, :rho,
                  :open_interest, :time_value, :theoretical_option_value,
                  :theoretical_volatility, :option_deliverables_list,
                  :expiration_date, :days_to_expiration, :expiration_type, :last_trading_day,
                  :multiplier, :settlement_type, :deliverable_note, :percent_change,
                  :mark_change, :mark_percent_change, :intrinsic_value, :extrinsic_value,
                  :option_root, :exercise_type, :high_52_week, :low_52_week, :non_standard,
                  :in_the_money

      def strike_price
        strike
      end
    end
  end
end
