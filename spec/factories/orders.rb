require_relative 'mock_response'

module ResponseFactory
  def self.order_response
    MockResponse.new(
      body: {
        "orderId" => "12345",
        "status" => "FILLED",
        "filledQuantity" => 100,
        "remainingQuantity" => 0,
        "price" => 150.0
      }.to_json,
      status: 200
    )
  end

  def self.cancel_order_response
    MockResponse.new(
      body: {
        "orderId" => "12345",
        "status" => "CANCELLED"
      }.to_json,
      status: 200
    )
  end

  def self.account_orders_response
    MockResponse.new(
      body: [
        {
          "orderId" => "12345",
          "status" => "FILLED",
          "filledQuantity" => 100,
          "remainingQuantity" => 0,
          "price" => 150.0
        },
        {
          "orderId" => "67890",
          "status" => "PENDING",
          "filledQuantity" => 0,
          "remainingQuantity" => 100,
          "price" => 155.0
        }
      ].to_json,
      status: 200
    )
  end

  def self.all_linked_account_orders_response
    MockResponse.new(
      body: [
        {
          "orderId" => "12345",
          "status" => "FILLED",
          "filledQuantity" => 100,
          "remainingQuantity" => 0,
          "price" => 150.0
        },
        {
          "orderId" => "67890",
          "status" => "PENDING",
          "filledQuantity" => 0,
          "remainingQuantity" => 100,
          "price" => 155.0
        }
      ].to_json,
      status: 200
    )
  end

  def self.place_order_response
    MockResponse.new(
      body: {
        "orderId" => "12345",
        "status" => "PENDING"
      }.to_json,
      status: 201
    )
  end

  def self.replace_order_response
    MockResponse.new(
      body: {
        "orderId" => "12345",
        "status" => "REPLACED"
      }.to_json,
      status: 200
    )
  end

  def self.preview_order_response
    MockResponse.new(
      body: {
        "orderId" => "12345",
        "status" => "PREVIEW"
      }.to_json,
      status: 200
    )
  end
end

module OrderStatus
  PENDING = "pending"
  COMPLETED = "completed"
  CANCELLED = "cancelled"
end
