module SchwabRb
  class Order
    module Statuses
      AWAITING_PARENT_ORDER = "AWAITING_PARENT_ORDER"
      AWAITING_CONDITION = "AWAITING_CONDITION"
      AWAITING_STOP_CONDITION = "AWAITING_STOP_CONDITION"
      AWAITING_MANUAL_REVIEW = "AWAITING_MANUAL_REVIEW"
      ACCEPTED = "ACCEPTED"
      AWAITING_UR_OUT = "AWAITING_UR_OUT"
      PENDING_ACTIVATION = "PENDING_ACTIVATION"
      QUEUED = "QUEUED"
      WORKING = "WORKING"
      REJECTED = "REJECTED"
      PENDING_CANCEL = "PENDING_CANCEL"
      CANCELED = "CANCELED"
      PENDING_REPLACE = "PENDING_REPLACE"
      REPLACED = "REPLACED"
      FILLED = "FILLED"
      EXPIRED = "EXPIRED"
      NEW = "NEW"
      AWAITING_RELEASE_TIME = "AWAITING_RELEASE_TIME"
      PENDING_ACKNOWLEDGEMENT = "PENDING_ACKNOWLEDGEMENT"
      PENDING_RECALL = "PENDING_RECALL"
      UNKNOWN = "UNKNOWN"
    end

    module Types
      # Execute the order immediately at the best-available price.
      # More Info <https://www.investopedia.com/terms/m/marketorder.asp>
      MARKET = "MARKET"

      # Execute the order at your price or better.
      # More info <https://www.investopedia.com/terms/l/limitorder.asp>
      LIMIT = "LIMIT"

      # Wait until the price reaches the stop price, and then immediately place a market order.
      # More Info <https://www.investopedia.com/terms/l/limitorder.asp>
      STOP = "STOP"

      # Wait until the price reaches the stop price, and then immediately place a
      # limit order at the specified price. `More Info
      # <https://www.investopedia.com/terms/s/stop-limitorder.asp>
      STOP_LIMIT = "STOP_LIMIT"

      # Similar to `STOP`, except if the price moves in your favor, the stop
      # price is adjusted in that direction. Places a market order if the stop
      # condition is met.
      # More info <https://www.investopedia.com/terms/t/trailingstop.asp>`
      TRAILING_STOP = "TRAILING_STOP"
      CABINET = "CABINET"
      NON_MARKETABLE = "NON_MARKETABLE"

      # Place the order at the closing price immediately upon market close.
      # More info <https://www.investopedia.com/terms/m/marketonclose.asp>
      MARKET_ON_CLOSE = "MARKET_ON_CLOSE"

      # Exercise an option.
      EXERCISE = "EXERCISE"

      # Similar to ``STOP_LIMIT``, except if the price moves in your favor, the
      # stop price is adjusted in that direction. Places a limit order at the
      # specified price if the stop condition is met.
      # More info <https://www.investopedia.com/terms/t/trailingstop.asp>
      TRAILING_STOP_LIMIT = "TRAILING_STOP_LIMIT"

      # Place an order for an options spread resulting in a net debit.
      # More info <https://www.investopedia.com/ask/answers/042215/
      # whats-difference-between-credit-spread-and-debt-spread.asp>
      NET_DEBIT = "NET_DEBIT"

      # Place an order for an options spread resulting in a net credit.
      # More info <https://www.investopedia.com/ask/answers/042215/
      # whats-difference-between-credit-spread-and-debt-spread.asp>
      NET_CREDIT = "NET_CREDIT"

      # Place an order for an options spread resulting in neither a credit nor a debit.
      # More info <https://www.investopedia.com/ask/answers/042215/
      # whats-difference-between-credit-spread-and-debt-spread.asp>
      NET_ZERO = "NET_ZERO"
      LIMIT_ON_CLOSE = "LIMIT_ON_CLOSE"
    end

    module ComplexOrderStrategyTypes
      # Explicit order strategies for executing multi-leg options orders.

      # No complex order strategy. This is the default.
      NONE = "NONE"

      # `Covered call <https://tickertape.tdameritrade.com/trading/
      # selling-covered-call-options-strategy-income-hedging-15135>`__
      COVERED = "COVERED"

      # `Vertical spread <https://tickertape.tdameritrade.com/trading/
      # vertical-credit-spreads-high-probability-15846>`__
      VERTICAL = "VERTICAL"

      # `Ratio backspread <https://tickertape.tdameritrade.com/trading/
      # pricey-stocks-ratio-spreads-15306>`__
      BACK_RATIO = "BACK_RATIO"

      # `Calendar spread <https://tickertape.tdameritrade.com/trading/
      # calendar-spreads-trading-primer-15095>`__
      CALENDAR = "CALENDAR"

      # `Diagonal spread <https://tickertape.tdameritrade.com/trading/
      # love-your-diagonal-spread-15030>`__
      DIAGONAL = "DIAGONAL"

      # `Straddle spread <https://tickertape.tdameritrade.com/trading/
      # straddle-strangle-option-volatility-16208>`__
      STRADDLE = "STRADDLE"

      # `Strandle spread <https://tickertape.tdameritrade.com/trading/
      # straddle-strangle-option-volatility-16208>`__
      STRANGLE = "STRANGLE"

      COLLAR_SYNTHETIC = "COLLAR_SYNTHETIC"

      # `Butterfly spread <https://tickertape.tdameritrade.com/trading/
      # butterfly-spread-options-15976>`__
      BUTTERFLY = "BUTTERFLY"

      # `Condor spread <https://www.investopedia.com/terms/c/
      # condorspread.asp>`__
      CONDOR = "CONDOR"

      # `Iron condor spread <https://tickertape.tdameritrade.com/trading/
      # iron-condor-options-spread-your-trading-wings-15948>`__
      IRON_CONDOR = "IRON_CONDOR"

      # `Roll a vertical spread <https://tickertape.tdameritrade.com/trading/
      # exit-winning-losing-trades-16685>`__
      VERTICAL_ROLL = "VERTICAL_ROLL"

      # `Collar strategy <https://tickertape.tdameritrade.com/trading/
      # stock-hedge-options-collars-15529>`__
      COLLAR_WITH_STOCK = "COLLAR_WITH_STOCK"

      # `Double diagonal spread <https://optionstradingiq.com/
      # the-ultimate-guide-to-double-diagonal-spreads/>`__
      DOUBLE_DIAGONAL = "DOUBLE_DIAGONAL"

      # `Unbalanced butterfy spread  <https://tickertape.tdameritrade.com/
      # trading/unbalanced-butterfly-strong-directional-bias-15913>`__
      UNBALANCED_BUTTERFLY = "UNBALANCED_BUTTERFLY"
      UNBALANCED_CONDOR = "UNBALANCED_CONDOR"
      UNBALANCED_IRON_CONDOR = "UNBALANCED_IRON_CONDOR"
      UNBALANCED_VERTICAL_ROLL = "UNBALANCED_VERTICAL_ROLL"

      # Mutual fund swap
      MUTUAL_FUND_SWAP = "MUTUAL_FUND_SWAP"

      # A custom multi-leg order strategy.
      CUSTOM = "CUSTOM"
    end
  end
end
