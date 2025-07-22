# frozen_string_literal: true

require_relative "instrument"
require_relative "position"

module SchwabRb
  module DataObjects
    class InitialBalances
      attr_reader :accrued_interest, :cash_balance,
                  :cash_receipts, :long_option_market_value,
                  :liquidation_value, :money_market_fund,
                  :available_funds_non_marginable_trade,
                  :bond_value, :buying_power, :cash_available_for_trading,
                  :day_trading_buying_power, :day_trading_buying_power_call,
                  :day_trading_equity_call, :equity, :equity_percentage,
                  :long_margin_value, :long_stock_value, :maintenance_call, :maintenance_requirement,
                  :margin, :margin_equity, :mutual_fund_value, :reg_t_call, :short_margin_value,
                  :short_option_market_value, :short_stock_value, :total_cash, :is_in_call,
                  :pending_deposits, :margin_balance, :short_balance, :account_value

      class << self
        def build(data)
          new(
            accrued_interest: data[:accruedInterest],
            cash_balance: data[:cashBalance],
            cash_receipts: data[:cashReceipts],
            long_option_market_value: data[:longOptionMarketValue],
            liquidation_value: data[:liquidationValue],
            money_market_fund: data[:moneyMarketFund],
            available_funds_non_marginable_trade: data[:availableFundsNonMarginableTrade],
            bond_value: data[:bondValue],
            buying_power: data[:buyingPower],
            cash_available_for_trading: data[:cashAvailableForTrading],
            day_trading_buying_power: data[:dayTradingBuyingPower],
            day_trading_buying_power_call: data[:dayTradingBuyingPowerCall],
            day_trading_equity_call: data[:dayTradingEquityCall],
            equity: data[:equity],
            equity_percentage: data[:equityPercentage],
            long_margin_value: data[:longMarginValue],
            long_stock_value: data[:longStockValue],
            maintenance_call: data[:maintenanceCall],
            maintenance_requirement: data[:maintenanceRequirement],
            margin: data[:margin],
            margin_equity: data[:marginEquity],
            mutual_fund_value: data[:mutualFundValue],
            reg_t_call: data[:regTCall],
            short_margin_value: data[:shortMarginValue],
            short_option_market_value: data[:shortOptionMarketValue],
            short_stock_value: data[:shortStockValue],
            total_cash: data[:totalCash],
            is_in_call: data[:isInCall],
            pending_deposits: data[:pendingDeposits],
            margin_balance: data[:marginBalance],
            short_balance: data[:shortBalance],
            account_value: data[:accountValue]
          )
        end
      end

      def initialize(
        accrued_interest:, cash_balance:, cash_receipts:, long_option_market_value:, liquidation_value:,
        money_market_fund:, available_funds_non_marginable_trade:, bond_value:, buying_power:,
        cash_available_for_trading:, day_trading_buying_power:, day_trading_buying_power_call:,
        day_trading_equity_call:, equity:, equity_percentage:, long_margin_value:, long_stock_value:,
        maintenance_call:, maintenance_requirement:, margin:, margin_equity:, mutual_fund_value:,
        reg_t_call:, short_margin_value:, short_option_market_value:, short_stock_value:, total_cash:,
        is_in_call:, pending_deposits:, margin_balance:, short_balance:, account_value:
      )
        @accrued_interest = accrued_interest
        @cash_balance = cash_balance
        @cash_receipts = cash_receipts
        @long_option_market_value = long_option_market_value
        @liquidation_value = liquidation_value
        @money_market_fund = money_market_fund
        @available_funds_non_marginable_trade = available_funds_non_marginable_trade
        @bond_value = bond_value
        @buying_power = buying_power
        @cash_available_for_trading = cash_available_for_trading
        @day_trading_buying_power = day_trading_buying_power
        @day_trading_buying_power_call = day_trading_buying_power_call
        @day_trading_equity_call = day_trading_equity_call
        @equity = equity
        @equity_percentage = equity_percentage
        @long_margin_value = long_margin_value
        @long_stock_value = long_stock_value
        @maintenance_call = maintenance_call
        @maintenance_requirement = maintenance_requirement
        @margin = margin
        @margin_equity = margin_equity
        @mutual_fund_value = mutual_fund_value
        @reg_t_call = reg_t_call
        @short_margin_value = short_margin_value
        @short_option_market_value = short_option_market_value
        @short_stock_value = short_stock_value
        @total_cash = total_cash
        @is_in_call = is_in_call
        @pending_deposits = pending_deposits
        @margin_balance = margin_balance
        @short_balance = short_balance
        @account_value = account_value
      end
    end

    class CurrentBalances
      attr_reader :accrued_interest, :cash_balance, :cash_receipts, :long_option_market_value,
                  :liquidation_value, :long_market_value, :money_market_fund, :savings,
                  :short_market_value, :pending_deposits, :mutual_fund_value, :bond_value,
                  :short_option_market_value, :available_funds, :available_funds_non_marginable_trade,
                  :buying_power, :buying_power_non_marginable_trade, :day_trading_buying_power,
                  :equity, :equity_percentage, :long_margin_value, :maintenance_call,
                  :maintenance_requirement, :margin_balance, :reg_t_call, :short_balance,
                  :short_margin_value, :sma

      class << self
        def build(data)
          new(
            accrued_interest: data[:accruedInterest],
            cash_balance: data[:cashBalance],
            cash_receipts: data[:cashReceipts],
            long_option_market_value: data[:longOptionMarketValue],
            liquidation_value: data[:liquidationValue],
            long_market_value: data[:longMarketValue],
            money_market_fund: data[:moneyMarketFund],
            savings: data[:savings],
            short_market_value: data[:shortMarketValue],
            pending_deposits: data[:pendingDeposits],
            mutual_fund_value: data[:mutualFundValue],
            bond_value: data[:bondValue],
            short_option_market_value: data[:shortOptionMarketValue],
            available_funds: data[:availableFunds],
            available_funds_non_marginable_trade: data[:availableFundsNonMarginableTrade],
            buying_power: data[:buyingPower],
            buying_power_non_marginable_trade: data[:buyingPowerNonMarginableTrade],
            day_trading_buying_power: data[:dayTradingBuyingPower],
            equity: data[:equity],
            equity_percentage: data[:equityPercentage],
            long_margin_value: data[:longMarginValue],
            maintenance_call: data[:maintenanceCall],
            maintenance_requirement: data[:maintenanceRequirement],
            margin_balance: data[:marginBalance],
            reg_t_call: data[:regTCall],
            short_balance: data[:shortBalance],
            short_margin_value: data[:shortMarginValue],
            sma: data[:sma]
          )
        end
      end

      def initialize(
        accrued_interest:, cash_balance:, cash_receipts:, long_option_market_value:, liquidation_value:,
        long_market_value:, money_market_fund:, savings:, short_market_value:, pending_deposits:,
        mutual_fund_value:, bond_value:, short_option_market_value:, available_funds:,
        available_funds_non_marginable_trade:, buying_power:, buying_power_non_marginable_trade:,
        day_trading_buying_power:, equity:, equity_percentage:, long_margin_value:, maintenance_call:,
        maintenance_requirement:, margin_balance:, reg_t_call:, short_balance:, short_margin_value:,
        sma:
      )
        @accrued_interest = accrued_interest
        @cash_balance = cash_balance
        @cash_receipts = cash_receipts
        @long_option_market_value = long_option_market_value
        @liquidation_value = liquidation_value
        @long_market_value = long_market_value
        @money_market_fund = money_market_fund
        @savings = savings
        @short_market_value = short_market_value
        @pending_deposits = pending_deposits
        @mutual_fund_value = mutual_fund_value
        @bond_value = bond_value
        @short_option_market_value = short_option_market_value
        @available_funds = available_funds
        @available_funds_non_marginable_trade = available_funds_non_marginable_trade
        @buying_power = buying_power
        @buying_power_non_marginable_trade = buying_power_non_marginable_trade
        @day_trading_buying_power = day_trading_buying_power
        @equity = equity
        @equity_percentage = equity_percentage
        @long_margin_value = long_margin_value
        @maintenance_call = maintenance_call
        @maintenance_requirement = maintenance_requirement
        @margin_balance = margin_balance
        @reg_t_call = reg_t_call
        @short_balance = short_balance
        @short_margin_value = short_margin_value
        @sma = sma
      end
    end

    class ProjectedBalances
      attr_reader :available_funds, :available_funds_non_marginable_trade, :buying_power,
                  :day_trading_buying_power, :day_trading_buying_power_call, :maintenance_call,
                  :reg_t_call, :is_in_call, :stock_buying_power

      class << self
        def build(data)
          new(
            available_funds: data[:availableFunds],
            available_funds_non_marginable_trade: data[:availableFundsNonMarginableTrade],
            buying_power: data[:buyingPower],
            day_trading_buying_power: data[:dayTradingBuyingPower],
            day_trading_buying_power_call: data[:dayTradingBuyingPowerCall],
            maintenance_call: data[:maintenanceCall],
            reg_t_call: data[:regTCall],
            is_in_call: data[:isInCall],
            stock_buying_power: data[:stockBuyingPower]
          )
        end
      end

      def initialize(
        available_funds:, available_funds_non_marginable_trade:, buying_power:, day_trading_buying_power:,
        day_trading_buying_power_call:, maintenance_call:, reg_t_call:, is_in_call:, stock_buying_power:
      )
        @available_funds = available_funds
        @available_funds_non_marginable_trade = available_funds_non_marginable_trade
        @buying_power = buying_power
        @day_trading_buying_power = day_trading_buying_power
        @day_trading_buying_power_call = day_trading_buying_power_call
        @maintenance_call = maintenance_call
        @reg_t_call = reg_t_call
        @is_in_call = is_in_call
        @stock_buying_power = stock_buying_power
      end
    end

    class AggregatedBalance
      class << self
        def build(data)
          new(
            current_liquidation_value: data.fetch(:currentLiquidationValue),
            liquidation_value: data.fetch(:liquidationValue)
          )
        end
      end

      def initialize(current_liquidation_value:, liquidation_value:)
        @current_liquidation_value = current_liquidation_value
        @liquidation_value = liquidation_value
      end

      attr_reader :current_liquidation_value, :liquidation_value
    end

    class Account
      class << self
        def build(data)
          data = data[:securitiesAccount] if data.key?(:securitiesAccount)
          new(
            type: data.fetch(:type),
            account_number: data.fetch(:accountNumber),
            round_trips: data.fetch(:roundTrips),
            is_day_trader: data.fetch(:isDayTrader),
            is_closing_only_restricted: data.fetch(:isClosingOnlyRestricted),
            pfcb_flag: data.fetch(:pfcbFlag),
            positions: data.fetch(:positions, []).map { |position| Position.build(position) },
            initial_balances: InitialBalances.build(data.fetch(:initialBalances)),
            current_balances: CurrentBalances.build(data.fetch(:currentBalances)),
            projected_balances: ProjectedBalances.build(data.fetch(:projectedBalances))
          )
        end
      end

      def initialize(type:, account_number:, round_trips:, is_day_trader:, is_closing_only_restricted:,
                     pfcb_flag:, initial_balances:, current_balances:, projected_balances:, positions: [])
        @type = type
        @account_number = account_number
        @round_trips = round_trips
        @is_day_trader = is_day_trader
        @is_closing_only_restricted = is_closing_only_restricted
        @pfcb_flag = pfcb_flag
        @positions = positions
        @initial_balances = initial_balances
        @current_balances = current_balances
        @projected_balances = projected_balances
      end

      attr_reader :type, :account_number, :round_trips, :is_day_trader, :is_closing_only_restricted,
                  :pfcb_flag, :positions, :initial_balances, :current_balances, :projected_balances
    end
  end
end
