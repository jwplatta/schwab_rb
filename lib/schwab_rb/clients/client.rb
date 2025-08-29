# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require_relative "base_client"
require_relative "../utils/logger"
require_relative "../utils/redactor"

module SchwabRb
  class Client < BaseClient
    BASE_URL = "https://api.schwabapi.com"

    private

    def get(path, params = {})
      dest = URI(URI::DEFAULT_PARSER.escape("#{BASE_URL}#{path}"))
      dest.query = URI.encode_www_form(params) if params.any?

      req_num = req_num()
      log_request("GET", req_num, dest, params)
      response = session.get(dest)

      log_response(response, req_num)
      response
    rescue StandardError => e
      log_error(e, req_num)
      raise e
    end

    def post(path, data = {})
      dest = URI(URI::DEFAULT_PARSER.escape("#{BASE_URL}#{path}"))

      req_num = req_num()
      log_request("POST", req_num, dest, data)

      response = session.post(
        dest,
        {
          body: data.to_json,
          headers: { "Content-Type" => "application/json" }
        }
      )
      log_response(response, req_num)
      response
    rescue StandardError => e
      log_error(e, req_num)
      raise e
    end

    def put(path, data = {})
      dest = URI(URI::DEFAULT_PARSER.escape("#{BASE_URL}#{path}"))

      req_num = req_num()
      log_request("PUT", req_num, dest, data)

      response = session.put(
        dest,
        {
          body: data.to_json,
          headers: { "Content-Type" => "application/json" }
        }
      )
      log_response(response, req_num)
      response
    rescue StandardError => e
      log_error(e, req_num)
      raise e
    end

    def delete(path)
      dest = URI(URI::DEFAULT_PARSER.escape("#{BASE_URL}#{path}"))

      req_num = req_num()
      log_request("DELETE", req_num, dest)

      response = session.delete(dest)
      log_response(response, req_num)
      response
    rescue StandardError => e
      log_error(e, req_num)
      raise e
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

    def log_error(error, req_num)
      SchwabRb::Logger.logger.error("Req #{req_num}: Error - #{error.message}")
      SchwabRb::Logger.logger.debug("Backtrace: #{error.backtrace.join("\n")}")
    end

    def req_num
      @request_counter ||= 0
      @request_counter += 1
    end
  end
end
