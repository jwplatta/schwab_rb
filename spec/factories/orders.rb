module ResponseFactory
  def self.OrderResponse
    OpenStruct.new(
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

  def self.CancelOrderResponse
    OpenStruct.new(
      body: {
        "orderId" => "12345",
        "status" => "CANCELLED"
      }.to_json,
      status: 200
    )
  end

  def self.AccountOrdersResponse
    OpenStruct.new(
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

  def self.AllLinkedAccountOrdersResponse
    OpenStruct.new(
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

  def self.PlaceOrderResponse
    OpenStruct.new(
      body: {
        "orderId" => "12345",
        "status" => "PENDING"
      }.to_json,
      status: 201
    )
  end

  def self.ReplaceOrderResponse
    OpenStruct.new(
      body: {
        "orderId" => "12345",
        "status" => "REPLACED"
      }.to_json,
      status: 200
    )
  end

  def self.PreviewOrderResponse
    OpenStruct.new(
      body: {
        "orderId" => "12345",
        "status" => "PREVIEW"
      }.to_json,
      status: 200
    )
  end
end

module OrderStatus
  PENDING = 'pending'
  COMPLETED = 'completed'
  CANCELLED = 'cancelled'
end
