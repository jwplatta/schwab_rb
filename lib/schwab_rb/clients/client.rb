# frozen_string_literal: true

require "json"
require "net/http"
require "uri"
require_relative "base_client"

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
      register_redactions_from_response(response)
      response
    end

    def post(path, data = {})
      dest = URI(URI::DEFAULT_PARSER.escape("#{BASE_URL}#{path}"))

      req_num = req_num()
      log_request("POST", req_num, dest, data)

      response = session.post(
        dest,
        {
          :body => data.to_json,
          :headers => { "Content-Type" => "application/json" }
        }
      )
      log_response(response, req_num)
      register_redactions_from_response(response)
      response
    end

    def put(path, data = {})
      dest = URI(URI::DEFAULT_PARSER.escape("#{BASE_URL}#{path}"))

      req_num = req_num()
      log_request("PUT", req_num, dest, data)

      response = session.put(
        dest,
        {
          :body => data.to_json,
          :headers => { "Content-Type" => "application/json" }
        }
      )
      log_response(response, req_num)
      register_redactions_from_response(response)
      response
    end

    def delete(path)
      dest = URI(URI::DEFAULT_PARSER.escape("#{BASE_URL}#{path}"))

      req_num = req_num()
      log_request("DELETE", req_num, dest)

      response = session.delete(dest)
      log_response(response, req_num)
      register_redactions_from_response(response)
      response
    end

    def log_request(method, req_num, dest, data = nil)
      puts "Req #{req_num}: #{method} to #{dest}"
      puts "Payload: #{JSON.pretty_generate(data)}" if data
    end

    def log_response(response, req_num)
      puts "Resp #{req_num}: Status #{response.status}"
    end

    def req_num
      @request_counter ||= 0
      @request_counter += 1
    end

    def register_redactions_from_response(response)
      # Placeholder for redaction logic
    end
  end
end
