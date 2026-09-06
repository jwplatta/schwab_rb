# frozen_string_literal: true

require "async"
require_relative "base"

module SchwabRb
  module Stream
    class Client
      def initialize(client)
        @stream = Base.new(client)
        @thread = nil
      end

      def on(service_symbol, symbols: nil, fields: nil, &block)
        @stream.on(service_symbol, symbols: symbols, fields: fields, &block)
        self
      end

      def start
        @thread = Thread.new do
          @stream.start
        end
        @thread.join
      end

      def start_async
        @thread = Thread.new do
          @stream.start
        end
        self
      end

      def stop
        @stream.stop
        @thread&.join(5)
        @thread = nil
      end

      def connected?
        @stream.connected?
      end
    end
  end
end
