require 'async'
require 'async/http'
require 'json'
require 'uri'
require_relative 'base_client'
require_relative '../utils/logger'
require_relative '../constants'

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
        log_request('GET', req_num, dest, params)

        # Use path only since @endpoint already has the base URL
        query_string = params.any? ? "?#{URI.encode_www_form(params)}" : ""
        response = @client.get("#{path}#{query_string}", build_headers)

        log_response(response, req_num)
        register_redactions_from_response(response)
        response
      end
    end

    def post(path, data = {})
      Async do
        refresh_token_if_needed
        dest = URI(URI::DEFAULT_PARSER.escape("#{SchwabRb::Constants::SCHWAB_BASE_URL}#{path}"))

        req_num = req_num()
        log_request('POST', req_num, dest, data)

        response = @client.post(path, build_headers, JSON.dump(data))

        log_response(response, req_num)
        register_redactions_from_response(response)
        response
      end
    end

    def put(path, data = {})
      Async do
        refresh_token_if_needed
        dest = URI(URI::DEFAULT_PARSER.escape("#{SchwabRb::Constants::SCHWAB_BASE_URL}#{path}"))

        req_num = req_num()
        log_request('PUT', req_num, dest, data)

        response = @client.put(path, build_headers, JSON.dump(data))

        log_response(response, req_num)
        register_redactions_from_response(response)
        response
      end
    end

    def delete(path)
      Async do
        refresh_token_if_needed
        dest = URI(URI::DEFAULT_PARSER.escape("#{SchwabRb::Constants::SCHWAB_BASE_URL}#{path}"))

        req_num = req_num()
        log_request('DELETE', req_num, dest)

        response = @client.delete(path, build_headers)

        log_response(response, req_num)
        register_redactions_from_response(response)
        response
      end
    end

    def register_redactions_from_response(response)
      # Implement the redaction logic here - placeholder for now
    end

    def build_headers
      headers = { "Content-Type" => "application/json" }
      
      # Add authorization header if token is available
      if @token_manager&.access_token
        headers["Authorization"] = "Bearer #{@token_manager.access_token}"
      end
      
      headers
    end

    def log_request(method, req_num, dest, data = nil)
      SchwabRb::Logger.logger.info("Req #{req_num}: #{method} to #{dest}")
      SchwabRb::Logger.logger.debug("Payload: #{JSON.pretty_generate(data)}") if data
    end

    def log_response(response, req_num)
      SchwabRb::Logger.logger.info("Resp #{req_num}: Status #{response.status}")
    end

    def req_num
      @request_counter ||= 0
      @request_counter += 1
    end
  end
end
