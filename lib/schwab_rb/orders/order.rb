module SchwabRb
  class Order
    module Status
      AWAITING_PARENT_ORDER = 'AWAITING_PARENT_ORDER'
      AWAITING_CONDITION = 'AWAITING_CONDITION'
      AWAITING_STOP_CONDITION = 'AWAITING_STOP_CONDITION'
      AWAITING_MANUAL_REVIEW = 'AWAITING_MANUAL_REVIEW'
      ACCEPTED = 'ACCEPTED'
      AWAITING_UR_OUT = 'AWAITING_UR_OUT'
      PENDING_ACTIVATION = 'PENDING_ACTIVATION'
      QUEUED = 'QUEUED'
      WORKING = 'WORKING'
      REJECTED = 'REJECTED'
      PENDING_CANCEL = 'PENDING_CANCEL'
      CANCELED = 'CANCELED'
      PENDING_REPLACE = 'PENDING_REPLACE'
      REPLACED = 'REPLACED'
      FILLED = 'FILLED'
      EXPIRED = 'EXPIRED'
      NEW = 'NEW'
      AWAITING_RELEASE_TIME = 'AWAITING_RELEASE_TIME'
      PENDING_ACKNOWLEDGEMENT = 'PENDING_ACKNOWLEDGEMENT'
      PENDING_RECALL = 'PENDING_RECALL'
      UNKNOWN = 'UNKNOWN'
    end

    module Type
      # Execute the order immediately at the best-available price.
      # More Info <https://www.investopedia.com/terms/m/marketorder.asp>
      MARKET = 'MARKET'

      # Execute the order at your price or better.
      # More info <https://www.investopedia.com/terms/l/limitorder.asp>
      LIMIT = 'LIMIT'

      # Wait until the price reaches the stop price, and then immediately place a market order.
      # More Info <https://www.investopedia.com/terms/l/limitorder.asp>
      STOP = 'STOP'

      # Wait until the price reaches the stop price, and then immediately place a
      # limit order at the specified price. `More Info
      # <https://www.investopedia.com/terms/s/stop-limitorder.asp>
      STOP_LIMIT = 'STOP_LIMIT'

      # Similar to `STOP`, except if the price moves in your favor, the stop
      # price is adjusted in that direction. Places a market order if the stop
      # condition is met.
      # More info <https://www.investopedia.com/terms/t/trailingstop.asp>`
      TRAILING_STOP = 'TRAILING_STOP'
      CABINET = 'CABINET'
      NON_MARKETABLE = 'NON_MARKETABLE'

      # Place the order at the closing price immediately upon market close.
      # More info <https://www.investopedia.com/terms/m/marketonclose.asp>
      MARKET_ON_CLOSE = 'MARKET_ON_CLOSE'

      # Exercise an option.
      EXERCISE = 'EXERCISE'

      # Similar to ``STOP_LIMIT``, except if the price moves in your favor, the
      # stop price is adjusted in that direction. Places a limit order at the
      # specified price if the stop condition is met.
      # More info <https://www.investopedia.com/terms/t/trailingstop.asp>
      TRAILING_STOP_LIMIT = 'TRAILING_STOP_LIMIT'

      # Place an order for an options spread resulting in a net debit.
      # More info <https://www.investopedia.com/ask/answers/042215/
      # whats-difference-between-credit-spread-and-debt-spread.asp>
      NET_DEBIT = 'NET_DEBIT'

      # Place an order for an options spread resulting in a net credit.
      # More info <https://www.investopedia.com/ask/answers/042215/
      # whats-difference-between-credit-spread-and-debt-spread.asp>
      NET_CREDIT = 'NET_CREDIT'

      # Place an order for an options spread resulting in neither a credit nor a debit.
      # More info <https://www.investopedia.com/ask/answers/042215/
      # whats-difference-between-credit-spread-and-debt-spread.asp>
      NET_ZERO = 'NET_ZERO'
      LIMIT_ON_CLOSE = 'LIMIT_ON_CLOSE'
    end

    def self.statuses
      Status.constants.map { |const| Status.const_get(const) }
    end

    def self.types
      Type.constants.map { |const| Type.const_get(const) }
    end
  end
end