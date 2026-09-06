# frozen_string_literal: true

require_relative "base"

module SchwabRb
  module Stream
    class AsyncClient
      def initialize(client)
        @stream = Base.new(client)
      end

      def on(service_symbol, symbols: nil, fields: nil, &block)
        @stream.on(service_symbol, symbols: symbols, fields: fields, &block)
        self
      end

      def start
        @stream.start
      end

      def stop
        @stream.stop
      end

      def connected?
        @stream.connected?
      end
    end
  end
end
