# frozen_string_literal: true

module ResponseFactory
  class AccountNumbersResponse
    def self.status
      200
    end

    def self.body
      [{
        "accountNumber" => "11111111",
        "hashValue" => "1111AA111A1111A1A1A1111AA11111A1111A111AA11AA1A1A11A1AA1A1111AA1"
      }].to_json
    end
  end

  class AccountResponse
    def self.status
      200
    end

    def self.body
      {
        "securitiesAccount" =>
          {
            "type" => "MARGIN",
            "accountNumber" => "11111111",
            "roundTrips" => 0,
            "isDayTrader" => false,
            "isClosingOnlyRestricted" => false,
            "pfcbFlag" => false,
            "initialBalances" =>
              {
                "accruedInterest" => 0.0,
                "availableFundsNonMarginableTrade" => 1000.01,
                "bondValue" => 10_000,
                "buyingPower" => 20_000,
                "cashBalance" => 1000.01,
                "cashAvailableForTrading" => 0.0,
                "cashReceipts" => 0.0,
                "dayTradingBuyingPower" => 24_000.0,
                "dayTradingBuyingPowerCall" => 0.0,
                "dayTradingEquityCall" => 0.0,
                "equity" => 0.0,
                "equityPercentage" => 0.0,
                "liquidationValue" => 1000.01,
                "longMarginValue" => 0.0,
                "longOptionMarketValue" => 0.0,
                "longStockValue" => 0.0,
                "maintenanceCall" => 0.0,
                "maintenanceRequirement" => 0.0,
                "margin" => 0.0,
                "marginEquity" => 0.0,
                "moneyMarketFund" => 0.0,
                "mutualFundValue" => 1000.01,
                "regTCall" => 0.0,
                "shortMarginValue" => 0.0,
                "shortOptionMarketValue" => 0.0,
                "shortStockValue" => 0.0,
                "totalCash" => 0.0,
                "isInCall" => false,
                "pendingDeposits" => 0.0,
                "marginBalance" => 0.0,
                "shortBalance" => 0.0,
                "accountValue" => 1000.01
              },
            "currentBalances" =>
              {
                "accruedInterest" => 0.0,
                "cashBalance" => 1000.01,
                "cashReceipts" => 0.0,
                "longOptionMarketValue" => 0.0,
                "liquidationValue" => 1000.01,
                "longMarketValue" => 0.0,
                "moneyMarketFund" => 0.0,
                "savings" => 0.0,
                "shortMarketValue" => 0.0,
                "pendingDeposits" => 0.0,
                "mutualFundValue" => 0.0,
                "bondValue" => 0.0,
                "shortOptionMarketValue" => 0.0,
                "availableFunds" => 1000.01,
                "availableFundsNonMarginableTrade" => 0.0,
                "buyingPower" => 20_000,
                "buyingPowerNonMarginableTrade" => 1000.01,
                "dayTradingBuyingPower" => 24_000.0,
                "equity" => 1000.01,
                "equityPercentage" => 100.0,
                "longMarginValue" => 0.0,
                "maintenanceCall" => 0.0,
                "maintenanceRequirement" => 0.0,
                "marginBalance" => 0.0,
                "regTCall" => 0.0,
                "shortBalance" => 0.0,
                "shortMarginValue" => 0.0,
                "sma" => 1000.01
              },
            "projectedBalances" =>
              {
                "availableFunds" => 1000.01,
                "availableFundsNonMarginableTrade" => 1000.01,
                "buyingPower" => 20_000,
                "dayTradingBuyingPower" => 24_000.0,
                "dayTradingBuyingPowerCall" => 0.0,
                "maintenanceCall" => 0.0,
                "regTCall" => 0.0,
                "isInCall" => false,
                "stockBuyingPower" => 20_000
              }
          },
        "aggregatedBalance" => {
          "currentLiquidationValue" => 1000.01, "liquidationValue" => 1000.01
        }
      }
    end
  end

  class AccountsResponse
    def self.status
      200
    end

    def self.body
      [{
        "securitiesAccount" => {
          "type" => "MARGIN",
          "accountNumber" => "11111111",
          "roundTrips" => 0,
          "isDayTrader" => false,
          "isClosingOnlyRestricted" => false,
          "pfcbFlag" => false,
          "initialBalances" => {
            "accruedInterest" => 0.0,
            "availableFundsNonMarginableTrade" => 1000.01,
            "bondValue" => 24_000.48,
            "buyingPower" => 12_000.24,
            "cashBalance" => 1000.01,
            "cashAvailableForTrading" => 0.0,
            "cashReceipts" => 0.0,
            "dayTradingBuyingPower" => 24_000.0,
            "dayTradingBuyingPowerCall" => 0.0,
            "dayTradingEquityCall" => 0.0,
            "equity" => 0.0,
            "equityPercentage" => 0.0,
            "liquidationValue" => 1000.01,
            "longMarginValue" => 0.0,
            "longOptionMarketValue" => 0.0,
            "longStockValue" => 0.0,
            "maintenanceCall" => 0.0,
            "maintenanceRequirement" => 0.0,
            "margin" => 0.0,
            "marginEquity" => 0.0,
            "moneyMarketFund" => 0.0,
            "mutualFundValue" => 1000.01,
            "regTCall" => 0.0,
            "shortMarginValue" => 0.0,
            "shortOptionMarketValue" => 0.0,
            "shortStockValue" => 0.0,
            "totalCash" => 0.0,
            "isInCall" => false,
            "pendingDeposits" => 0.0,
            "marginBalance" => 0.0,
            "shortBalance" => 0.0,
            "accountValue" => 1000.01
          },
          "currentBalances" => {
            "accruedInterest" => 0.0,
            "cashBalance" => 1000.01,
            "cashReceipts" => 0.0,
            "longOptionMarketValue" => 0.0,
            "liquidationValue" => 1000.01,
            "longMarketValue" => 0.0,
            "moneyMarketFund" => 0.0,
            "savings" => 0.0,
            "shortMarketValue" => 0.0,
            "pendingDeposits" => 0.0,
            "mutualFundValue" => 0.0,
            "bondValue" => 0.0,
            "shortOptionMarketValue" => 0.0,
            "availableFunds" => 1000.01,
            "availableFundsNonMarginableTrade" => 0.0,
            "buyingPower" => 12_000.24,
            "buyingPowerNonMarginableTrade" => 1000.01,
            "dayTradingBuyingPower" => 24_000.0,
            "equity" => 1000.01,
            "equityPercentage" => 100.0,
            "longMarginValue" => 0.0,
            "maintenanceCall" => 0.0,
            "maintenanceRequirement" => 0.0,
            "marginBalance" => 0.0,
            "regTCall" => 0.0,
            "shortBalance" => 0.0,
            "shortMarginValue" => 0.0,
            "sma" => 1000.01
          },
          "projectedBalances" => {
            "availableFunds" => 1000.01,
            "availableFundsNonMarginableTrade" => 1000.01,
            "buyingPower" => 12_000.24,
            "dayTradingBuyingPower" => 24_000.0,
            "dayTradingBuyingPowerCall" => 0.0,
            "maintenanceCall" => 0.0,
            "regTCall" => 0.0,
            "isInCall" => false,
            "stockBuyingPower" => 12_000.24
          }
        },
        "aggregatedBalance" => {
          "currentLiquidationValue" => 1000.01,
          "liquidationValue" => 1000.01
        }
      }].to_json
    end
  end
end
