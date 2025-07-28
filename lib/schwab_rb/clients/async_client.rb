# frozen_string_literal: true

require "async"
require "async/http"
require "json"
require "uri"
require_relative "base_client"
require_relative "../utils/logger"
require_relative "../utils/redactor"
require_relative "../constants"

module SchwabRb
  class AsyncClient < BaseClient
    def initialize(api_key, app_secret, session, token_manager:, enforce_enums: true)
      super
      @endpoint = Async::HTTP::Endpoint.parse(SchwabRb::Constants::SCHWAB_BASE_URL)
      @client = Async::HTTP::Client.new(@endpoint)
    end

    def close_async_session
      @client.close
    end

    private

    def get(path, params = {})
      Async do
        refresh_token_if_needed
        dest = URI(URI::DEFAULT_PARSER.escape("#{SchwabRb::Constants::SCHWAB_BASE_URL}#{path}"))
        dest.query = URI.encode_www_form(params) if params.any?

        req_num = req_num()
        log_request("GET", req_num, dest, params)

        # Use path only since @endpoint already has the base URL
        query_string = params.any? ? "?#{URI.encode_www_form(params)}" : ""
        response = @client.get("#{path}#{query_string}", build_headers)

        log_response(response, req_num)
        response
      end
    end

    def post(path, data = {})
      Async do
        refresh_token_if_needed
        dest = URI(URI::DEFAULT_PARSER.escape("#{SchwabRb::Constants::SCHWAB_BASE_URL}#{path}"))

        req_num = req_num()
        log_request("POST", req_num, dest, data)

        response = @client.post(path, build_headers, JSON.dump(data))

        log_response(response, req_num)
        response
      end
    end

    def put(path, data = {})
      Async do
        refresh_token_if_needed
        dest = URI(URI::DEFAULT_PARSER.escape("#{SchwabRb::Constants::SCHWAB_BASE_URL}#{path}"))

        req_num = req_num()
        log_request("PUT", req_num, dest, data)

        response = @client.put(path, build_headers, JSON.dump(data))

        log_response(response, req_num)
        response
      end
    end

    def delete(path)
      Async do
        refresh_token_if_needed
        dest = URI(URI::DEFAULT_PARSER.escape("#{SchwabRb::Constants::SCHWAB_BASE_URL}#{path}"))

        req_num = req_num()
        log_request("DELETE", req_num, dest)

        response = @client.delete(path, build_headers)

        log_response(response, req_num)
        response
      end
    end

    def build_headers
      headers = { "Content-Type" => "application/json" }

      # Add authorization header if token is available
      headers["Authorization"] = "Bearer #{@token_manager.access_token}" if @token_manager&.access_token

      headers
    end

    def log_request(method, req_num, dest, data = nil)
      redacted_dest = SchwabRb::Redactor.redact_url(dest.to_s)
      SchwabRb::Logger.logger.info("Req #{req_num}: #{method} to #{redacted_dest}")

      return unless data

      redacted_data = SchwabRb::Redactor.redact_data(data)
      SchwabRb::Logger.logger.debug("Payload: #{JSON.pretty_generate(redacted_data)}")
    end

    def log_response(response, req_num)
      SchwabRb::Logger.logger.info("Resp #{req_num}: Status #{response.status}")

      return unless SchwabRb::Logger.logger.level == ::Logger::DEBUG

      redacted_body = SchwabRb::Redactor.redact_response_body(response)
      SchwabRb::Logger.logger.debug("Response body: #{JSON.pretty_generate(redacted_body)}") if redacted_body
    end

    def req_num
      @request_counter ||= 0
      @request_counter += 1
    end
  end
end
