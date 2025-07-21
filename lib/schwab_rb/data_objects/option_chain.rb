# frozen_string_literal: true

require "json"
require "date"
require_relative "option"

module SchwabRb
  module DataObjects
    class OptionChain
      class << self
        def build(data)
          underlying_symbol = data.fetch(:symbol)

          call_dates = []
          call_opts = []
          data.fetch(:callExpDateMap).each do |exp_date, options|
            call_dates << Date.strptime(exp_date.to_s.split(":").first, "%Y-%m-%d")
            options.each_value do |opts|
              opts.each do |option_data|
                call_opts << Option.build(underlying_symbol, option_data)
              end
            end
          end

          put_dates = []
          put_opts = []
          data.fetch(:putExpDateMap).each do |exp_date, options|
            put_dates << Date.strptime(exp_date.to_s.split(":").first, "%Y-%m-%d")

            options.each_value do |opts|
              opts.each do |option_data|
                put_opts << Option.build(underlying_symbol, option_data)
              end
            end
          end

          new(
            symbol: data.fetch(:symbol),
            status: data.fetch(:status),
            strategy: data.fetch(:strategy),
            interval: data.fetch(:interval, nil),
            is_delayed: data.fetch(:isDelayed, nil),
            is_index: data.fetch(:isIndex, nil),
            interest_rate: data.fetch(:interestRate, nil),
            underlying_price: data.fetch(:underlyingPrice),
            volatility: data.fetch(:volatility, nil),
            days_to_expiration: data.fetch(:daysToExpiration),
            asset_main_type: data.fetch(:assetMainType, nil),
            asset_sub_type: data.fetch(:assetSubType, nil),
            is_chain_truncated: data.fetch(:isChainTruncated, false),
            call_dates: call_dates,
            call_opts: call_opts,
            put_dates: put_dates,
            put_opts: put_opts
          )
        end
      end

      def initialize(
        symbol:, status:, strategy:, interval:, is_delayed:, is_index:, interest_rate:, underlying_price:, volatility:, days_to_expiration:, asset_main_type:, asset_sub_type:, is_chain_truncated:, call_dates: [], call_opts: [], put_dates: [], put_opts: []
      )
        @symbol = symbol
        @status = status
        @strategy = strategy
        @interval = interval
        @is_delayed = is_delayed
        @is_index = is_index
        @interest_rate = interest_rate
        @underlying_price = underlying_price
        @volatility = volatility
        @days_to_expiration = days_to_expiration
        @asset_main_type = asset_main_type
        @asset_sub_type = asset_sub_type
        @is_chain_truncated = is_chain_truncated
        @call_dates = call_dates
        @call_opts = call_opts
        @put_dates = put_dates
        @put_opts = put_opts
      end

      attr_reader :symbol, :status, :strategy, :interval, :is_delayed, :is_index, :interest_rate, :underlying_price,
                  :volatility, :days_to_expiration, :asset_main_type, :asset_sub_type, :is_chain_truncated, :call_dates, :call_opts, :put_dates, :put_opts

      def to_a(_date = nil)
        call_opts.map do |copt|
          [copt.expiration_date.strftime("%Y-%m-%d"), copt.put_call, copt.strike, copt.delta, copt.bid, copt.ask,
           copt.mark]
        end + put_opts.map do |popt|
          [popt.expiration_date.strftime("%Y-%m-%d"), popt.put_call, popt.strike, popt.delta, popt.bid, popt.ask,
           popt.mark]
        end
      end
    end
  end
end
