require_relative '../utils/enum_enforcer'

module SchwabRb::Orders
  class Builder
    # Helper class to create arbitrarily complex orders. Note this class simply
    # implements the order schema defined in the `documentation
    # <https://developer.schwabmeritrade.com/account-access/apis/post/accounts/
    # %7BaccountId%7D/orders-0>`__, with no attempts to validate the result.
    # Orders created using this class may be rejected or may never fill. Use at
    # your own risk.

    include EnumEnforcer

    class << self
      def build(obj)
        case obj
        when String, Integer, Float
          obj
        when Hash
          obj.each_with_object({}) { |(key, val), acc| acc[key] = build(val) }
        when Array
          obj.map { |i| build(i) }
        else
          ret = {}
          obj.instance_variables.each do |var|
            value = obj.instance_variable_get(var)
            next if value.nil?

            name = var.to_s[1..-1]
            ret[name] = build(value)
          end
          ret
        end
      end
    end

    def initialize(enforce_enums: true)
      @session = nil
      @duration = nil
      @order_type = nil
      @complex_order_strategy_type = nil
      @quantity = nil
      @destination_link_name = nil
      @stop_price = nil
      @stop_price_link_basis = nil
      @stop_price_link_type = nil
      @stop_price_offset = nil
      @stop_type = nil
      @price_link_basis = nil
      @price_link_type = nil
      @price = nil
      @order_leg_collection = nil
      @activation_price = nil
      @special_instruction = nil
      @order_strategy_type = nil
      @child_order_strategies = nil
    end

    def set_session(session)
      @session = convert_enum(session, SchwabRb::Orders::Session)
      self
    end

    def clear_session
      @session = nil
      self
    end

    def set_duration(duration)
      @duration = convert_enum(duration, SchwabRb::Orders::Duration)
      self
    end

    def clear_duration
      @duration = nil
      self
    end

    def set_order_type(order_type)
      @order_type = convert_enum(order_type, SchwabRb::Order::Types)
      self
    end

    def clear_order_type
      @order_type = nil
      self
    end

    def set_quantity(quantity)
      raise 'quantity must be positive' if quantity <= 0

      @quantity = quantity
      self
    end

    def clear_quantity
      @quantity = nil
      self
    end

    def set_stop_price(stop_price)
      @stop_price = stop_price.is_a?(String) ? stop_price : truncate_float(stop_price)
      self
    end

    def copy_stop_price(stop_price)
      @stop_price = stop_price
      self
    end

    def clear_stop_price
      @stop_price = nil
      self
    end

    def add_child_order_strategy(child_order_strategy)
      raise 'child order must be OrderBuilder or Hash' unless [Builder, Hash].any? { |c| child_order_strategy.is_a?(c) }

      @child_order_strategies ||= []
      @child_order_strategies << child_order_strategy
      self
    end

    def clear_child_order_strategies
      @child_order_strategies = nil
      self
    end

    def add_equity_leg(instruction, symbol, quantity)
      raise 'quantity must be positive' if quantity <= 0

      @order_leg_collection ||= []
      @order_leg_collection << {
        instruction: convert_enum(instruction, SchwabRb::Orders::EquityInstructions),
        instrument: SchwabRb::Orders::EquityInstrument.new(symbol),
        quantity: quantity
      }
      self
    end

    def clear_order_legs
      @order_leg_collection = nil
      self
    end

    def build
      Builder.build(self)
    end

    private

    def truncate_float(flt)
      if flt.abs < 1 && flt != 0.0
        format('%.4f', (flt * 10000).to_i / 10000.0)
      else
        format('%.2f', (flt * 100).to_i / 100.0)
      end
    end
  end
end
