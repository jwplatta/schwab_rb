# frozen_string_literal: true

require "async"
require "async/websocket/client"
require "json"
require_relative "services"
require_relative "fields"
require_relative "message_builder"

module SchwabRb
  module Stream
    class Base
      INITIAL_BACKOFF = 2
      MAX_BACKOFF = 120
      MIN_CONNECTION_TIME = 90

      attr_reader :client

      def initialize(client)
        @client = client
        @handlers = {}
        @subscriptions = {}
        @connection = nil
        @message_builder = nil
        @streamer_info = nil
        @connected = false
        @connect_time = nil
        @backoff_time = INITIAL_BACKOFF
        @should_run = false
      end

      def on(service_symbol, symbols: nil, fields: nil, &block)
        service_name = Services.lookup(service_symbol)
        resolved_fields = fields ? Fields.resolve(service_name, fields) : nil

        handler = { symbols: Array(symbols), fields: resolved_fields, callback: block }
        @handlers[service_name] ||= []
        @handlers[service_name] << handler

        @subscriptions[service_name] = merge_subscription(
          @subscriptions[service_name],
          handler
        )

        send_subscription(service_name, handler) if @connected

        self
      end

      def start
        @should_run = true
        Async do |task|
          loop do
            connect
            run_receive_loop
          rescue StandardError => e
            handle_disconnect(e)
            break unless should_reconnect?

            wait_and_reconnect(task)
          end
        end
      end

      def stop
        @should_run = false
        disconnect
      end

      def connected?
        @connected
      end

      private

      def connect
        fetch_streamer_info
        open_websocket
        login
        send_pending_subscriptions
        @connected = true
        @connect_time = Time.now
        @backoff_time = INITIAL_BACKOFF
      end

      def disconnect
        return unless @connection

        begin
          logout_request = @message_builder.build_logout
          send_message(@message_builder.wrap_requests(logout_request))
        rescue StandardError
          # best-effort logout
        end

        @connection.close
        @connection = nil
        @connected = false
      end

      def fetch_streamer_info
        @client.refresh! if @client.session.expired?
        prefs = @client.get_user_preferences
        @streamer_info = prefs.streamer_info.first

        raise "No streamer info available" unless @streamer_info

        @message_builder = MessageBuilder.new(
          @streamer_info.schwab_client_customer_id,
          @streamer_info.schwab_client_correl_id
        )
      end

      def open_websocket
        url = @streamer_info.streamer_socket_url
        endpoint = Async::HTTP::Endpoint.parse(url)
        @connection = Async::WebSocket::Client.connect(endpoint)
      end

      def login
        access_token = @client.token_manager.token.token
        login_request = @message_builder.build_login(
          access_token,
          @streamer_info.schwab_client_channel,
          @streamer_info.schwab_client_function_id
        )

        send_message(login_request.to_json)

        response = @connection.read
        parsed = JSON.parse(response.to_str)

        login_response = parsed.dig("response", 0) || parsed
        code = login_response.dig("content", "code")

        return if code.to_i.zero? || code == 0

        raise "Login failed: #{login_response}"
      end

      def send_pending_subscriptions
        @subscriptions.each do |service_name, sub|
          request = @message_builder.build_request(
            service_name, Commands::SUBS,
            keys: sub[:symbols],
            fields: sub[:fields]
          )
          send_message(@message_builder.wrap_requests(request))
        end
      end

      def send_subscription(service_name, handler)
        request = @message_builder.build_request(
          service_name, Commands::ADD,
          keys: handler[:symbols],
          fields: handler[:fields]
        )
        send_message(@message_builder.wrap_requests(request))
      end

      def run_receive_loop
        while @connected && @should_run
          message = @connection.read
          break if message.nil?

          parsed = JSON.parse(message.to_str)
          dispatch_message(parsed)
        end
      end

      def dispatch_message(parsed)
        if parsed.key?("data")
          parsed["data"].each do |data_entry|
            service = data_entry["service"]
            handlers = @handlers[service]
            next unless handlers

            handlers.each { |h| h[:callback]&.call(data_entry) }
          end
        end

        return unless parsed.key?("response")

        parsed["response"].each do |resp|
          SchwabRb::Logger.logger.debug("Stream response: #{resp}")
        end
      end

      def handle_disconnect(error)
        @connected = false
        begin
          @connection&.close
        rescue StandardError
          nil
        end
        @connection = nil

        SchwabRb::Logger.logger.warn("Stream disconnected: #{error.message}")
      end

      def should_reconnect?
        return false unless @should_run
        return false unless @connect_time

        elapsed = Time.now - @connect_time
        if elapsed < MIN_CONNECTION_TIME
          SchwabRb::Logger.logger.error(
            "Stream connection failed after #{elapsed.round(1)}s (< #{MIN_CONNECTION_TIME}s). " \
            "This likely indicates a configuration error. Not reconnecting."
          )
          return false
        end

        true
      end

      def wait_and_reconnect(task)
        SchwabRb::Logger.logger.info("Reconnecting in #{@backoff_time}s...")
        task.sleep(@backoff_time)
        @backoff_time = [@backoff_time * 2, MAX_BACKOFF].min
      end

      def send_message(json_string)
        @connection.write(Protocol::WebSocket::TextMessage.generate(json_string))
        @connection.flush
      end

      def merge_subscription(existing, handler)
        if existing
          {
            symbols: (existing[:symbols] + handler[:symbols]).uniq,
            fields: existing[:fields] && handler[:fields] ? (existing[:fields] + handler[:fields]).uniq : nil
          }
        else
          { symbols: handler[:symbols].dup, fields: handler[:fields]&.dup }
        end
      end
    end
  end
end
