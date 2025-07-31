# frozen_string_literal: true

require_relative "instrument"

module SchwabRb
  module DataObjects
    class TransferItem
      class << self
        def build(data)
          TransferItem.new(
            instrument: Instrument.build(data.fetch(:instrument)),
            amount: data.fetch(:amount),
            cost: data.fetch(:cost),
            fee_type: data.fetch(:feeType, nil),
            position_effect: data.fetch(:positionEffect, nil)
          )
        end
      end

      attr_reader :instrument, :amount, :cost, :fee_type, :position_effect

      def initialize(instrument:, amount:, cost:, fee_type:, position_effect:)
        @instrument = instrument
        @amount = amount
        @cost = cost
        @fee_type = fee_type
        @position_effect = position_effect
      end

      def symbol
        option? ? instrument.symbol : ""
      end

      def underlying_symbol
        option? ? instrument.underlying_symbol : ""
      end

      def description
        option? ? instrument.description : ""
      end

      def option?
        instrument.option?
      end

      def put_call
        instrument.put_call
      end

      def credit_debit?
        fee_type.nil?
      end

      def fee?
        %w[OPT_REG_FEE TAF_FEE SEC_FEE].include?(fee_type)
      end

      def commission?
        fee_type == "COMMISSION"
      end

      def to_h
        {
          instrument: instrument.to_h,
          amount: amount,
          cost: cost,
          fee_type: fee_type,
          position_effect: position_effect
        }
      end
    end

    class Transaction
      class << self
        def build(data)
          Transaction.new(
            activity_id: data.fetch(:activityId),
            time: data.fetch(:time),
            type: data.fetch(:type),
            status: data.fetch(:status),
            sub_account: data.fetch(:subAccount),
            trade_date: data.fetch(:tradeDate),
            position_id: data.fetch(:positionId, nil),
            order_id: data.fetch(:orderId, nil),
            net_amount: data.fetch(:netAmount, nil),
            transfer_items: data.fetch(:transferItems).map { |ti| TransferItem.build(ti) }
          )
        end
      end

      def initialize(activity_id:, time:, type:, status:, sub_account:, trade_date:, position_id:, order_id:,
                     net_amount:, transfer_items: [])
        @activity_id = activity_id
        @time = time
        @type = type
        @status = status
        @sub_account = sub_account
        @trade_date = trade_date
        @position_id = position_id
        @order_id = order_id
        @net_amount = net_amount
        @transfer_items = transfer_items
      end

      attr_reader :activity_id, :time, :type, :status, :sub_account, :trade_date, :position_id, :order_id, :net_amount,
                  :transfer_items

      def trade?
        type == "TRADE"
      end

      def credit_debits
        transfer_items.select(&:credit_debit?).map { |ti| ti.cost }
      end

      def fees
        transfer_items.select(&:fee?).map { |ti| ti.cost }
      end

      def commissions
        transfer_items.select(&:commission?).map { |ti| ti.cost }
      end

      def symbols
        transfer_items.map { |ti| ti.instrument.symbol }
      end

      def option_symbol
        transfer_items.find { |ti| ti.instrument.option? }.instrument.symbol
      end

      def to_h
        {
          activity_id: @activity_id,
          time: @time,
          type: @type,
          status: @status,
          sub_account: @sub_account,
          trade_date: @trade_date,
          position_id: @position_id,
          order_id: @order_id,
          net_amount: @net_amount,
          transfer_items: @transfer_items.map(&:to_h)
        }
      end
    end
  end
end
