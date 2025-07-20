require_relative 'mock_response'

module ResponseFactory
  def self.transactions_response
    MockResponse.new(
      body: File.read('./spec/factories/body_json/transactions_response_body.json'),
      status: 200
    )
  end

  def self.transaction_response
    MockResponse.new(
      body: {
        "activityId" => 90957056499,
        "time" => "2025-01-14T05:15:12+0000",
        "accountNumber" => "111111111",
        "type" => "TRADE",
        "status" => "VALID",
        "subAccount" => "MARGIN",
        "tradeDate" => "2025-01-14T05:15:12+0000",
        "positionId" => 2709980218,
        "orderId" => 1111111111111,
        "netAmount" => -1052.82,
        "transferItems" => [
          {
            "instrument" => {
              "assetType" => "CURRENCY",
              "status" => "ACTIVE",
              "symbol" => "CURRENCY_USD",
              "description" => "USD currency",
              "instrumentId" => 1,
              "closingPrice" => 0
            },
            "amount" => 2.25,
            "cost" => -2.25,
            "feeType" => "COMMISSION"
          }
        ]
      }.to_json,
      status: 200
    )
  end
end
