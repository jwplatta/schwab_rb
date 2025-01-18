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
      body: File.read('./spec/factories/body_json/transaction_response_body.json'),
      status: 200
    )
  end
end
