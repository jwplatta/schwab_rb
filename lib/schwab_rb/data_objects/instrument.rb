# frozen_string_literal: true

module SchwabRb
  module DataObjects
    class Asset
      attr_reader :asset_type, :status, :symbol, :instrument_id, :closing_price, :type, :description,
                  :active_contract, :expiration_date, :last_trading_date, :multiplier, :future_type

      def self.build(data)
        new(
          asset_type: data.fetch(:assetType, nil),
          status: data.fetch(:status, nil),
          symbol: data.fetch(:symbol, nil),
          instrument_id: data.fetch(:instrumentId, nil),
          closing_price: data.fetch(:closingPrice, nil),
          type: data.fetch(:type, nil),
          description: data.fetch(:description, nil),
          active_contract: data.fetch(:activeContract, nil),
          expiration_date: data.fetch(:expirationDate, nil),
          last_trading_date: data.fetch(:lastTradingDate, nil),
          multiplier: data.fetch(:multiplier, nil),
          future_type: data.fetch(:futureType, nil)
        )
      end

      def initialize(
        asset_type: nil, status: nil, symbol: nil, instrument_id: nil, closing_price: nil, type: nil, description: nil, active_contract: nil, expiration_date: nil, last_trading_date: nil, multiplier: nil, future_type: nil
      )
        @asset_type = asset_type
        @status = status
        @symbol = symbol
        @instrument_id = instrument_id
        @closing_price = closing_price
        @type = type
        @description = description
        @active_contract = active_contract
        @expiration_date = expiration_date
        @last_trading_date = last_trading_date
        @multiplier = multiplier
        @future_type = future_type
      end

      def to_h
        {
          assetType: @asset_type,
          status: @status,
          symbol: @symbol,
          instrumentId: @instrument_id,
          closingPrice: @closing_price,
          type: @type,
          description: @description,
          activeContract: @active_contract,
          expirationDate: @expiration_date,
          lastTradingDate: @last_trading_date,
          multiplier: @multiplier,
          futureType: @future_type
        }.compact
      end
    end

    class OptionDeliverable
      attr_reader :root_symbol, :symbol, :deliverable_units, :deliverable_number, :strike_percent, :deliverable

      def self.build(data)
        new(
          root_symbol: data.fetch(:rootSymbol, nil),
          symbol: data.fetch(:symbol, nil),
          strike_percent: data.fetch(:strikePercent, nil),
          deliverable_number: data.fetch(:deliverableNumber, nil),
          deliverable_units: data.fetch(:deliverableUnits),
          deliverable: data.fetch(:deliverable, nil).then { |d| d.nil? ? nil : Instrument.build(d) }
        )
      end

      def initialize(root_symbol:, symbol:, deliverable_units:, deliverable_number:, strike_percent:, deliverable:)
        @root_symbol = root_symbol
        @symbol = symbol
        @deliverable_units = deliverable_units
        @deliverable_number = deliverable_number
        @strike_percent = strike_percent
        @deliverable = deliverable
      end

      def to_h
        {
          rootSymbol: @root_symbol,
          symbol: @symbol,
          strikePercent: @strike_percent,
          deliverableNumber: @deliverable_number,
          deliverableUnits: @deliverable_units,
          deliverable: @deliverable&.to_h
        }.compact
      end
    end

    class Instrument
      attr_reader :asset_type, :cusip, :symbol, :description, :net_change, :type, :put_call,
                  :underlying_symbol, :status, :instrument_id, :closing_price, :option_deliverables

      def self.build(data)
        new(
          asset_type: data.fetch(:assetType),
          symbol: data.fetch(:symbol, nil),
          description: data.fetch(:description, nil),
          cusip: data.fetch(:cusip, nil),
          net_change: data.fetch(:netChange, nil),
          type: data.fetch(:type, nil),
          put_call: data.fetch(:putCall, nil),
          underlying_symbol: data.fetch(:underlyingSymbol, nil),
          status: data.fetch(:status, nil),
          instrument_id: data.fetch(:instrumentId, nil),
          closing_price: data.fetch(:closingPrice, nil),
          option_deliverables: data.fetch(:optionDeliverables, []).map { |d| OptionDeliverable.build(d) }
        )
      end

      def initialize(
        symbol:, description:, asset_type: nil, cusip: nil, net_change: nil, type: nil, put_call: nil, underlying_symbol: nil, status: nil, instrument_id: nil, closing_price: nil, option_deliverables: []
      )
        @asset_type = asset_type
        @cusip = cusip
        @symbol = symbol
        @description = description
        @net_change = net_change
        @type = type
        @put_call = put_call
        @underlying_symbol = underlying_symbol
        @status = status
        @instrument_id = instrument_id
        @closing_price = closing_price
        @option_deliverables = option_deliverables
      end

      def option?
        asset_type == "OPTION"
      end

      def equity?
        asset_type == "EQUITY"
      end

      def to_h
        {
          assetType: @asset_type,
          symbol: @symbol,
          description: @description,
          cusip: @cusip,
          netChange: @net_change,
          type: @type,
          putCall: @put_call,
          underlyingSymbol: @underlying_symbol,
          status: @status,
          instrumentId: @instrument_id,
          closingPrice: @closing_price,
          optionDeliverables: @option_deliverables.map(&:to_h)
        }.compact
      end
    end
  end
end
