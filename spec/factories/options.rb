require_relative 'mock_response'

module ResponseFactory
  def self.option
    MockResponse.new(
      body: {},
      status: 500
    )
  end

  def self.option_chain
    MockResponse.new(
      body: {},
      status: 500
    )
  end
end
