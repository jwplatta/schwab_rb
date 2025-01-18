# frozen_string_literal: true

class Schwab
  DEFAULT_TOKEN_PATH = './tmp/token.json'
  class << self
    def build(auth, api_key, redirect_uri, token_path: DEFAULT_TOKEN_PATH, async: false)
      ClientBuilder.build()

      self.new(auth, api_key, redirect_uri, token_path: token_path, async: async)
    end
  end

  def initialize(client: nil)
    @client = client
  end

  attr_reader :client
end
