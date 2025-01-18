module ResponseFactory
  class MockResponse
    def initialize(body:, status:)
      @body = body
      @status = status
    end

    attr_reader :body, :status
  end
end
