# frozen_string_literal: true

require_relative 'order_leg'

module SchwabRb
  module DataObjects
    class ExecutionLeg
      attr_reader :leg_id, :quantity, :mismarked_quantity, :price, :time, :instrument_id

      class << self
        def build(data)
          new(
            leg_id: data[:legId],
            quantity: data[:quantity],
            mismarked_quantity: data[:mismarkedQuantity],
            price: data[:price],
            time: data[:time],
            instrument_id: data[:instrumentId]
          )
        end
      end

      def initialize(leg_id:, quantity:, mismarked_quantity:, price:, time:, instrument_id:)
        @leg_id = leg_id
        @quantity = quantity
        @mismarked_quantity = mismarked_quantity
        @price = price
        @time = time
        @instrument_id = instrument_id
      end

      def to_h
        {
          legId: @leg_id,
          quantity: @quantity,
          mismarkedQuantity: @mismarked_quantity,
          price: @price,
          time: @time,
          instrumentId: @instrument_id
        }
      end
    end

    class OrderActivity
      attr_reader :activity_type, :activity_id, :execution_type, :quantity, :order_remaining_quantity, :execution_legs

      class << self
        def build(data)
          new(
            activity_type: data[:activityType],
            activity_id: data[:activityId],
            execution_type: data[:executionType],
            quantity: data[:quantity],
            order_remaining_quantity: data[:orderRemainingQuantity],
            execution_legs: data.fetch(:executionLegs, []).map { |leg| ExecutionLeg.build(leg) }
          )
        end
      end

      def initialize(activity_type:, activity_id:, execution_type:, quantity:, order_remaining_quantity:, execution_legs:)
        @activity_type = activity_type
        @activity_id = activity_id
        @execution_type = execution_type
        @quantity = quantity
        @order_remaining_quantity = order_remaining_quantity
        @execution_legs = execution_legs
      end

      def to_h
        {
          activityType: @activity_type,
          activityId: @activity_id,
          executionType: @execution_type,
          quantity: @quantity,
          orderRemainingQuantity: @order_remaining_quantity,
          executionLegs: @execution_legs.map(&:to_h)
        }
      end
    end

    class Order
      attr_reader :duration, :order_type, :complex_order_strategy_type, :quantity,
                  :filled_quantity, :remaining_quantity, :price, :order_leg_collection, :order_strategy_type, :order_id, :status, :entered_time, :close_time, :order_activity_collection

      class << self
        def build(data)
          # Parse datetime strings into DateTime objects
          entered_time = parse_datetime(data[:enteredTime])
          close_time = parse_datetime(data[:closeTime])

          new(
            duration: data[:duration],
            order_type: data[:orderType],
            complex_order_strategy_type: data[:complexOrderStrategyType],
            quantity: data[:quantity],
            filled_quantity: data[:filledQuantity],
            remaining_quantity: data[:remainingQuantity],
            price: data[:price],
            order_leg_collection: data.fetch(:orderLegCollection, []).map { |leg| OrderLeg.build(leg) },
            order_strategy_type: data[:orderStrategyType],
            order_id: data[:orderId],
            status: data[:status],
            entered_time: entered_time,
            close_time: close_time,
            order_activity_collection: data.fetch(:orderActivityCollection, []).map do |activity|
              OrderActivity.build(activity)
            end
          )
        end

        private

        def parse_datetime(datetime_str)
          return nil if datetime_str.nil? || datetime_str.empty?

          begin
            DateTime.parse(datetime_str)
          rescue ArgumentError
            nil
          end
        end
      end

      def initialize(
        duration:, order_type:, complex_order_strategy_type:, quantity:, filled_quantity:,
        remaining_quantity:, price:, order_strategy_type:, order_id:, status:, entered_time:, close_time:, order_leg_collection: [], order_activity_collection: []
      )
        @duration = duration
        @order_type = order_type
        @complex_order_strategy_type = complex_order_strategy_type
        @quantity = quantity
        @filled_quantity = filled_quantity
        @remaining_quantity = remaining_quantity
        @price = price
        @order_leg_collection = order_leg_collection
        @order_strategy_type = order_strategy_type
        @order_id = order_id
        @status = status
        @entered_time = entered_time
        @close_time = close_time
        @order_activity_collection = order_activity_collection
      end

      def symbols
        order_leg_collection.map(&:symbol)
      end

      def strategy
        if %w[VERTICAL CUSTOM].include?(complex_order_strategy_type) && order_leg_collection.all?(&:call?)
          'CALL_SPREAD'
        elsif %w[VERTICAL CUSTOM].include?(complex_order_strategy_type) && order_leg_collection.all?(&:put?)
          'PUT_SPREAD'
        else
          order_strategy_type
        end
      end

      def close?
        order_leg_collection.all? { |leg| leg.position_effect == 'CLOSING' }
      end

      def open?
        order_leg_collection.all? { |leg| leg.position_effect == 'OPENING' }
      end

      def to_h
        {
          duration: @duration,
          orderType: @order_type,
          complexOrderStrategyType: @complex_order_strategy_type,
          quantity: @quantity,
          filledQuantity: @filled_quantity,
          remainingQuantity: @remaining_quantity,
          price: @price,
          orderLegCollection: @order_leg_collection.map(&:to_h),
          orderStrategyType: @order_strategy_type,
          orderId: @order_id,
          status: @status,
          enteredTime: @entered_time&.iso8601,
          closeTime: @close_time&.iso8601,
          orderActivityCollection: @order_activity_collection.map(&:to_h)
        }
      end
    end
  end
end
