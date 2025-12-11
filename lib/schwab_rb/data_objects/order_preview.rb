# frozen_string_literal: true

require_relative "order_leg"

module SchwabRb
  module DataObjects
    class OrderPreview
      attr_reader :order_id, :order_value, :order_strategy, :order_balance, :order_validation_result,
                  :commission_and_fee

      class << self
        def build(data)
          new(data)
        end
      end

      def initialize(attrs)
        @order_id = attrs[:orderId]
        @order_value = attrs[:orderValue]
        @order_strategy = attrs[:orderStrategy] ? OrderStrategy.new(attrs[:orderStrategy]) : nil
        @order_balance = attrs[:orderBalance] ? OrderBalance.new(attrs[:orderBalance]) : nil
        @order_validation_result = attrs[:orderValidationResult] ? OrderValidationResult.new(attrs[:orderValidationResult]) : nil
        @commission_and_fee = attrs[:commissionAndFee] ? CommissionAndFee.new(attrs[:commissionAndFee]) : nil
      end

      def status
        @order_strategy&.status
      end

      def price
        @order_strategy&.price
      end

      def quantity
        @order_strategy&.quantity
      end

      def accepted?
        status == "ACCEPTED"
      end

      def commission
        return 0.0 unless @commission_and_fee

        @commission_and_fee.commission
      end

      def fees
        return 0.0 unless @commission_and_fee

        @commission_and_fee.fee
      end

      def to_h
        {
          orderId: @order_id,
          orderValue: @order_value,
          orderStrategy: @order_strategy&.to_h,
          orderBalance: @order_balance&.to_h,
          orderValidationResult: @order_validation_result&.to_h,
          commissionAndFee: @commission_and_fee&.to_h
        }
      end

      class OrderStrategy
        attr_reader :status, :price, :quantity, :order_type, :type, :strategy_id, :order_legs

        def initialize(attrs)
          @status = attrs[:status]
          @price = attrs[:price]
          @quantity = attrs[:quantity]
          @order_type = attrs[:orderType]
          @type = attrs[:type]
          @strategy_id = attrs[:strategyId]
          @order_legs = attrs[:orderLegs]&.map { |leg| OrderLeg.build(leg) } || []
        end

        def to_h
          {
            status: @status,
            price: @price,
            quantity: @quantity,
            orderType: @order_type,
            type: @type,
            strategyId: @strategy_id,
            orderLegs: @order_legs.map(&:to_h)
          }
        end
      end

      class OrderBalance
        attr_reader :order_value, :projected_available_fund, :projected_buying_power, :projected_commission

        def initialize(attrs)
          @order_value = attrs[:orderValue]
          @projected_available_fund = attrs[:projectedAvailableFund]
          @projected_buying_power = attrs[:projectedBuyingPower]
          @projected_commission = attrs[:projectedCommission]
        end

        def to_h
          {
            orderValue: @order_value,
            projectedAvailableFund: @projected_available_fund,
            projectedBuyingPower: @projected_buying_power,
            projectedCommission: @projected_commission
          }
        end
      end

      class OrderValidationResult
        attr_reader :is_valid, :warns, :rejects

        def initialize(attrs)
          @is_valid = attrs[:isValid]
          @warns = attrs[:warns]&.map { |warn| Warn.new(warn) } || []
          @rejects = attrs[:rejects]&.map { |reject| Reject.new(reject) } || []
        end

        def to_h
          {
            isValid: @is_valid,
            warns: @warns.map(&:to_h),
            rejects: @rejects.map(&:to_h)
          }
        end

        class Warn
          attr_reader :activity_message, :original_severity

          def initialize(attrs)
            @activity_message = attrs[:activityMessage]
            @original_severity = attrs[:originalSeverity]
          end

          def to_h
            {
              activityMessage: @activity_message,
              originalSeverity: @original_severity
            }
          end
        end

        class Reject
          attr_reader :activity_message, :original_severity

          def initialize(attrs)
            @activity_message = attrs[:activityMessage]
            @original_severity = attrs[:originalSeverity]
          end

          def to_h
            {
              activityMessage: @activity_message,
              originalSeverity: @original_severity
            }
          end
        end
      end

      class CommissionAndFee
        attr_reader :commissions, :fees, :true_commission_legs

        def initialize(attrs)
          @commissions = attrs[:commission][:commissionLegs] || []
          @fees = attrs[:fee][:feeLegs] || []
          @true_commission_legs = attrs[:trueCommission][:commissionLegs] || []
        end

        def commission
          calculate_total_from_legs(@commissions, "COMMISSION")
        end

        def fee
          calculate_total_from_legs(@fees, %w[OPT_REG_FEE INDEX_OPTION_FEE])
        end

        def true_commission
          calculate_total_from_legs(@true_commission_legs, "COMMISSION")
        end

        def to_h
          {
            commission: commission,
            fee: fee,
            trueCommission: true_commission,
            commissions: @commissions,
            fees: @fees
          }
        end

        private

        def calculate_total_from_legs(legs, types)
          total = 0.0
          types = [types] unless types.is_a?(Array)

          legs.each do |leg|
            values = leg[:commissionValues] || leg[:feeValues] || []
            values.each do |value_item|
              total += value_item[:value] || 0.0 if types.include?(value_item[:type])
            end
          end

          total.round(2)
        end
      end
    end
  end
end
