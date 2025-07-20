# frozen_string_literal: true

require_relative 'order_leg'
require_relative 'instrument'

module SchwabRb
  module DataObjects
    class OrderPreview
      attr_accessor :order_id, :order_strategy, :order_validation_result, :commission_and_fee

      class << self
        def build(data)
          new(
            order_id: data[:orderId],
            order_strategy: data[:orderStrategy],
            order_validation_result: data[:orderValidationResult],
            commission_and_fee: data[:commissionAndFee]
          )
        end
      end

      def initialize(order_id:, order_strategy:, order_validation_result:, commission_and_fee:)
        @order_id = order_id
        @order_strategy = OrderStrategy.new(order_strategy)
        @order_validation_result = OrderValidationResult.new(order_validation_result)
        @commission_and_fee = CommissionAndFee.new(commission_and_fee)
      end

      def price
        order_strategy.price
      end

      def order_value
        order_strategy.order_value
      end

      def quantity
        order_strategy.quantity
      end

      def status
        order_strategy.status
      end

      def strategy_type
        order_strategy.strategy
      end

      def entered_time
        order_strategy.entered_time
      end

      def accepted?
        order_strategy.status == 'ACCEPTED'
      end

      def commission
        commission_and_fee.commission.value.round(2)
      end

      def fees
        commission_and_fee.fee.value.round(2)
      end

      def to_h
        {
          orderId: @order_id,
          orderStrategy: @order_strategy.to_h,
          orderValidationResult: @order_validation_result.to_h,
          commissionAndFee: @commission_and_fee.to_h
        }
      end

      class OrderStrategy
        attr_accessor :account_number, :advanced_order_type, :close_time, :entered_time, :order_balance,
                      :order_strategy_type, :order_version, :session, :status, :discretionary, :duration,
                      :filled_quantity, :order_type, :order_value, :price, :quantity, :remaining_quantity,
                      :sell_non_marginable_first, :strategy, :amount_indicator, :order_legs

        def initialize(attrs)
          @account_number = attrs[:accountNumber]
          @advanced_order_type = attrs[:advancedOrderType]
          @close_time = attrs[:closeTime]
          @entered_time = attrs[:enteredTime]
          @order_balance = OrderBalance.new(attrs[:orderBalance])
          @order_strategy_type = attrs[:orderStrategyType]
          @order_version = attrs[:orderVersion]
          @session = attrs[:session]
          @status = attrs[:status]
          @discretionary = attrs[:discretionary]
          @duration = attrs[:duration]
          @filled_quantity = attrs[:filledQuantity]
          @order_type = attrs[:orderType]
          @order_value = attrs[:orderValue]
          @price = attrs[:price]
          @quantity = attrs[:quantity]
          @remaining_quantity = attrs[:remainingQuantity]
          @sell_non_marginable_first = attrs[:sellNonMarginableFirst]
          @strategy = attrs[:strategy]
          @amount_indicator = attrs[:amountIndicator]
          @order_legs = attrs[:orderLegs].map do |leg|
            OrderLeg.build(leg)
          end
        end

        def to_h
          {
            accountNumber: @account_number,
            advancedOrderType: @advanced_order_type,
            closeTime: @close_time,
            enteredTime: @entered_time,
            orderBalance: @order_balance.to_h,
            orderStrategyType: @order_strategy_type,
            orderVersion: @order_version,
            session: @session,
            status: @status,
            discretionary: @discretionary,
            duration: @duration,
            filledQuantity: @filled_quantity,
            orderType: @order_type,
            orderValue: @order_value,
            price: @price,
            quantity: @quantity,
            remainingQuantity: @remaining_quantity,
            sellNonMarginableFirst: @sell_non_marginable_first,
            strategy: @strategy,
            amountIndicator: @amount_indicator,
            orderLegs: @order_legs.map(&:to_h)
          }
        end

        class OrderBalance
          attr_accessor :order_value, :projected_available_fund, :projected_buying_power, :projected_commission

          def initialize(attrs)
            @order_value = attrs[:orderValue]          @projected_available_fund = attrs[:projectedAvailableFund]
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
      end

      class OrderValidationResult
        attr_accessor :rejects

        def initialize(attrs)
          @rejects = attrs.fetch(:rejects, []).map { |reject| Reject.new(reject) }
        end

        def to_h
          {
            rejects: @rejects.map(&:to_h)
          }
        end

        class Reject
          attr_accessor :activity_message, :original_severity

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
        attr_accessor :commission, :fee, :true_commission

        def initialize(attrs)
          @commission = Commission.new(attrs[:commission])
          @fee = Fee.new(attrs[:fee])
          @true_commission = TrueCommission.new(attrs[:trueCommission])
        end

        def to_h
          {
            commission: @commission.to_h,
            fee: @fee.to_h,
            trueCommission: @true_commission.to_h
          }
        end

        class Commission
          attr_accessor :commission_legs

          def initialize(attrs)
            @commission_legs = attrs[:commissionLegs].map do |leg|
              CommissionLeg.new(leg)
            end
          end

          def value
            commission_legs.sum(&:value)
          end

          def to_h
            {
              commissionLegs: @commission_legs.map(&:to_h)
            }
          end

          class CommissionLeg
            attr_accessor :commission_values

            def initialize(attrs)
              @commission_values = attrs[:commissionValues].map do |val|
                CommissionValue.new(val)
              end
            end

            def value
              commission_values.sum(&:value)
            end

            def to_h
              {
                commissionValues: @commission_values.map(&:to_h)
              }
            end

            class CommissionValue
              attr_accessor :value, :type

              def initialize(attrs)
                @value = attrs[:value]
                @type = attrs[:type]
              end

              def to_h
                {
                  value: @value,
                  type: @type
                }
              end
            end
          end
        end

        class Fee
          attr_accessor :fee_legs

          def initialize(attrs)
            @fee_legs = attrs[:feeLegs].map { |leg| FeeLeg.new(leg) }
          end

          def value
            fee_legs.sum(&:value)
          end

          def to_h
            {
              feeLegs: @fee_legs.map(&:to_h)
            }
          end

          class FeeLeg
            attr_accessor :fee_values

            def initialize(attrs)
              @fee_values = attrs[:feeValues].map { |val| FeeValue.new(val) }
            end

            def value
              fee_values.sum(&:value)
            end

            def to_h
              {
                feeValues: @fee_values.map(&:to_h)
              }
            end

            class FeeValue
              attr_accessor :value, :type

              def initialize(attrs)
                @value = attrs[:value]
                @type = attrs[:type]
              end

              def to_h
                {
                  value: @value,
                  type: @type
                }
              end
            end
          end
        end

        class TrueCommission
          attr_accessor :commission_legs

          def initialize(attrs)
            @commission_legs = attrs[:commissionLegs].map do |leg|
              CommissionLeg.new(leg)
            end
          end

          def value
            commission_legs.sum(&:value)
          end

          def to_h
            {
              commissionLegs: @commission_legs.map(&:to_h)
            }
          end

          class CommissionLeg
            attr_accessor :commission_values

            def initialize(attrs)
              @commission_values = attrs[:commissionValues].map do |val|
                CommissionValue.new(val)
              end
            end

            def value
              commission_values.sum(&:value)
            end

            def to_h
              {
                commissionValues: @commission_values.map(&:to_h)
              }
            end

            class CommissionValue
              attr_accessor :value, :type

              def initialize(attrs)
                @value = attrs[:value]
                @type = attrs[:type]
              end

              def to_h
                {
                  value: @value,
                  type: @type
                }
              end
            end
          end
        end
      end
    end
  end
end
