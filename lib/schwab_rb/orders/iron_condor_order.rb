# frozen_string_literal: true

require "schwab_rb"

module SchwabRb
  module Orders
    class IronCondorOrder
      class << self
        def build(
          put_short_symbol:,
          put_long_symbol:,
          call_short_symbol:,
          call_long_symbol:,
          price:,
          stop_price: nil,
          order_type: nil,
          duration: SchwabRb::Orders::Duration::DAY,
          credit_debit: :credit,
          order_instruction: :open,
          quantity: 1
        )
          schwab_order_builder.new.tap do |builder|
            builder.set_order_strategy_type(SchwabRb::Order::OrderStrategyTypes::SINGLE)
            builder.set_session(SchwabRb::Orders::Session::NORMAL)
            builder.set_duration(duration)
            builder.set_order_type(order_type || determine_order_type(credit_debit))
            builder.set_complex_order_strategy_type(SchwabRb::Order::ComplexOrderStrategyTypes::IRON_CONDOR)
            builder.set_quantity(quantity)
            builder.set_price(price)
            builder.set_stop_price(stop_price) if stop_price && order_type == SchwabRb::Order::Types::STOP_LIMIT

            instructions = leg_instructions_for_position(order_instruction)

            builder.add_option_leg(
              instructions[:put_short],
              put_short_symbol,
              quantity
            )
            builder.add_option_leg(
              instructions[:put_long],
              put_long_symbol,
              quantity
            )
            builder.add_option_leg(
              instructions[:call_short],
              call_short_symbol,
              quantity
            )
            builder.add_option_leg(
              instructions[:call_long],
              call_long_symbol,
              quantity
            )
          end
        end

        def determine_order_type(credit_debit)
          if credit_debit == :credit
            SchwabRb::Order::Types::NET_CREDIT
          else
            SchwabRb::Order::Types::NET_DEBIT
          end
        end

        def leg_instructions_for_position(order_instruction)
          if order_instruction == :open
            {
              put_short: SchwabRb::Orders::OptionInstructions::SELL_TO_OPEN,
              put_long: SchwabRb::Orders::OptionInstructions::BUY_TO_OPEN,
              call_short: SchwabRb::Orders::OptionInstructions::SELL_TO_OPEN,
              call_long: SchwabRb::Orders::OptionInstructions::BUY_TO_OPEN
            }
          elsif order_instruction == :close
            {
              put_short: SchwabRb::Orders::OptionInstructions::BUY_TO_CLOSE,
              put_long: SchwabRb::Orders::OptionInstructions::SELL_TO_CLOSE,
              call_short: SchwabRb::Orders::OptionInstructions::BUY_TO_CLOSE,
              call_long: SchwabRb::Orders::OptionInstructions::SELL_TO_CLOSE
            }
          else
            raise "Unsupported order instruction: #{order_instruction}"
          end
        end

        def schwab_order_builder
          SchwabRb::Orders::Builder
        end
      end
    end
  end
end
