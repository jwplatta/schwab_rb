# frozen_string_literal: true

require_relative 'order_leg'
require_relative 'instrument'

module SchwabRb
  module DataObjects
    class OrderPreview
      attr_reader :order_id, :order_value, :order_strategy, :order_balance, :order_validation_result, :projected_commission

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
        commission_data = attrs[:commissionAndFee] || attrs[:projectedCommission]
        @projected_commission = commission_data ? CommissionAndFee.new(commission_data) : nil
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
        status == 'ACCEPTED'
      end

      def commission
        return 0.0 unless @projected_commission
        
        if @projected_commission.instance_variable_get(:@direct_commission)
          @projected_commission.instance_variable_get(:@direct_commission).to_f
        else
          @projected_commission.commission_total
        end
      end

      def fees
        return 0.0 unless @projected_commission
        
        if @projected_commission.instance_variable_get(:@direct_fee)
          @projected_commission.instance_variable_get(:@direct_fee).to_f
        else
          @projected_commission.fee_total
        end
      end

      def to_h
        {
          orderId: @order_id,
          orderValue: @order_value,
          orderStrategy: @order_strategy&.to_h,
          orderBalance: @order_balance&.to_h,
          orderValidationResult: @order_validation_result&.to_h,
          projectedCommission: @projected_commission&.to_h
        }
      end

      class OrderStrategy
        attr_reader :account_number, :status, :price, :quantity, :order_type, :type, :strategy_id, :order_legs

        def initialize(attrs)
          @account_number = attrs[:accountNumber]
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
            accountNumber: @account_number,
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
        attr_reader :commission_data, :fee_data, :true_commission_data

        def initialize(attrs)
          # Handle the actual API format where commission/fee data is at top level
          if attrs[:commissions] || attrs[:fees] || (attrs[:commission].is_a?(String) rescue false)
            # API format (like in fixtures)
            @commission_data = { commissionLegs: attrs[:commissions] || [] }
            @fee_data = { feeLegs: attrs[:fees] || [] }
            @true_commission_data = { commissionLegs: attrs[:commissions] || [] }
            @direct_commission = attrs[:commission]
            @direct_fee = attrs[:fee] 
            @direct_true_commission = attrs[:trueCommission]
          else
            # Nested format (for backwards compatibility)
            @commission_data = attrs[:commission] || {}
            @fee_data = attrs[:fee] || {}
            @true_commission_data = attrs[:trueCommission] || {}
          end
        end

        def commission_total
          calculate_total_from_legs(@commission_data[:commissionLegs] || [], 'COMMISSION')
        end

        def commission
          @direct_commission || sprintf("%.2f", commission_total)
        end

        def fee_total
          calculate_total_from_legs(@fee_data[:feeLegs] || [], ['OPT_REG_FEE', 'INDEX_OPTION_FEE'])
        end

        def fee
          @direct_fee || sprintf("%.2f", fee_total)
        end

        def true_commission_total
          calculate_total_from_legs(@true_commission_data[:commissionLegs] || [], 'COMMISSION')
        end

        def true_commission
          @direct_true_commission || sprintf("%.2f", true_commission_total * 2)
        end

        def commissions
          @commission_data[:commissionLegs] || []
        end

        def fees
          @fee_data[:feeLegs] || []
        end

        def to_h
          {
            commission: commission,
            fee: fee,
            trueCommission: true_commission,
            commissions: commissions,
            fees: fees
          }
        end

        private

        def calculate_total_from_legs(legs, types)
          total = 0.0
          types = [types] unless types.is_a?(Array)

          legs.each do |leg|
            values = leg[:commissionValues] || leg[:feeValues] || []
            values.each do |value_item|
              if types.include?(value_item[:type])
                total += (value_item[:value] || 0.0)
              end
            end
          end

          total.round(2)
        end
      end
    end
  end
end
