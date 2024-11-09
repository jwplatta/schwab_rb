class Schwab
  # Will wrap the client and auth workflows
  class << self
    def build(auth, api_key, redirect_uri, token_path: '/tmp/token.json', async: false)
      ClientBuilder.build()

      self.new(auth, api_key, redirect_uri, token_path: token_path, async: async)
    end
  end

  def initialize(client: nil)
    @client = client
  end

  attr_reader :client
end