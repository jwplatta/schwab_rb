# frozen_string_literal: true

require_relative "instrument"

module SchwabRb
  module DataObjects
    class OrderLeg
      attr_reader :leg_id, :order_leg_type, :quantity, :instrument, :instruction, :position_effect

      class << self
        def build(data)
          new(
            leg_id: data[:legId],
            order_leg_type: data[:orderLegType],
            quantity: data[:quantity],
            instrument: Instrument.build(data[:instrument]),
            instruction: data.fetch(:instruction, nil),
            position_effect: data[:positionEffect]
          )
        end
      end

      def initialize(leg_id:, order_leg_type:, quantity:, instrument:, instruction:, position_effect:)
        @leg_id = leg_id
        @order_leg_type = order_leg_type
        @quantity = quantity
        @instrument = instrument
        @instruction = instruction
        @position_effect = position_effect
      end

      def instrument_id
        instrument.instrument_id
      end

      def call?
        put_call == "CALL"
      end

      def close?
        position_effect == "CLOSING"
      end

      def open?
        position_effect == "OPENING"
      end

      def put?
        put_call == "PUT"
      end

      def put_call
        instrument.put_call
      end

      def symbol
        instrument.symbol
      end

      def description
        instrument.description
      end

      def to_h
        {
          legId: @leg_id,
          orderLegType: @order_leg_type,
          quantity: @quantity,
          instrument: @instrument.to_h,
          instruction: @instruction,
          positionEffect: @position_effect
        }
      end
    end
  end
end
