# frozen_string_literal: true

require_relative 'order_leg'
require_relative 'instrument'

module SchwabRb
  module DataObjects
    class OrderPreview
      attr_reader :order_value, :order_strategy, :order_balance, :order_validation_result, :projected_commission

      def initialize(attrs)
        @order_value = attrs[:orderValue]
        @order_strategy = attrs[:orderStrategy] ? OrderStrategy.new(attrs[:orderStrategy]) : nil
        @order_balance = attrs[:orderBalance] ? OrderBalance.new(attrs[:orderBalance]) : nil
        @order_validation_result = attrs[:orderValidationResult] ? OrderValidationResult.new(attrs[:orderValidationResult]) : nil
        @projected_commission = attrs[:projectedCommission] ? CommissionAndFee.new(attrs[:projectedCommission]) : nil
      end

      def to_h
        {
          orderValue: @order_value,
          orderStrategy: @order_strategy&.to_h,
          orderBalance: @order_balance&.to_h,
          orderValidationResult: @order_validation_result&.to_h,
          projectedCommission: @projected_commission&.to_h
        }
      end

      class OrderStrategy
        attr_reader :type, :strategy_id, :order_legs

        def initialize(attrs)
          @type = attrs[:type]
          @strategy_id = attrs[:strategyId]
          @order_legs = attrs[:orderLegs]&.map { |leg| OrderLeg.build(leg) } || []
        end

        def to_h
          {
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
        attr_reader :is_valid, :warning_message, :rejects

        def initialize(attrs)
          @is_valid = attrs[:isValid]
          @warning_message = attrs[:warningMessage]
          @rejects = attrs[:rejects]&.map { |reject| Reject.new(reject) } || []
        end

        def to_h
          {
            isValid: @is_valid,
            warningMessage: @warning_message,
            rejects: @rejects.map(&:to_h)
          }
        end

        class Reject
          attr_reader :reject_code, :reject_message

          def initialize(attrs)
            @reject_code = attrs[:rejectCode]
            @reject_message = attrs[:rejectMessage]
          end

          def to_h
            {
              rejectCode: @reject_code,
              rejectMessage: @reject_message
            }
          end
        end
      end

      class CommissionAndFee
        attr_reader :commission, :fee, :true_commission, :commissions, :fees

        def initialize(attrs)
          # Handle nested commissionAndFee structure
          if attrs[:commissionAndFee]
            fee_data = attrs[:commissionAndFee]
            @commission = fee_data[:commission]
            @fee = fee_data[:fee]
            @true_commission = fee_data[:trueCommission]
            @commissions = fee_data[:commissions] || []
            @fees = fee_data[:fees] || []
          else
            @commission = attrs[:commission]
            @fee = attrs[:fee]
            @true_commission = attrs[:trueCommission]
            @commissions = attrs[:commissions] || []
            @fees = attrs[:fees] || []
          end
        end

        def to_h
          {
            commission: @commission,
            fee: @fee,
            trueCommission: @true_commission,
            commissions: @commissions,
            fees: @fees
          }
        end
      end
    end
  end
end
