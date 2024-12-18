module SchwabRb
  class Transaction
    module Type
      TRADE = 'TRADE'
      RECEIVE_AND_DELIVER = 'RECEIVE_AND_DELIVER'
      DIVIDEND_OR_INTEREST = 'DIVIDEND_OR_INTEREST'
      ACH_RECEIPT = 'ACH_RECEIPT'
      ACH_DISBURSEMENT = 'ACH_DISBURSEMENT'
      CASH_RECEIPT = 'CASH_RECEIPT'
      CASH_DISBURSEMENT = 'CASH_DISBURSEMENT'
      ELECTRONIC_FUND = 'ELECTRONIC_FUND'
      WIRE_OUT = 'WIRE_OUT'
      WIRE_IN = 'WIRE_IN'
      JOURNAL = 'JOURNAL'
      MEMORANDUM = 'MEMORANDUM'
      MARGIN_CALL = 'MARGIN_CALL'
      MONEY_MARKET = 'MONEY_MARKET'
      SMA_ADJUSTMENT = 'SMA_ADJUSTMENT'

      def self.types
        Type.constants.map { |const| const_get(const) }
      end
    end
  end
end
