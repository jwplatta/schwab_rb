require 'async'
require 'async/http'
require 'json'
require_relative 'base_client'

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

    def get(path, params)
      Async do
        dest = "#{BASE_URL}#{path}"
        req_num = req_num()
        log_request('GET', req_num, dest, params)

        query = URI.encode_www_form(params)
        response = @client.get("#{dest}?#{query}")

        log_response(response, req_num)
        register_redactions_from_response(response)
        response
      end
    end

    def post(path, data)
      Async do
        dest = "#{BASE_URL}#{path}"
        req_num = req_num()
        log_request('POST', req_num, dest, data)

        response = @client.post(dest, {}, JSON.dump(data))

        log_response(response, req_num)
        register_redactions_from_response(response)
        response
      end
    end

    def put(path, data)
      Async do
        dest = "#{BASE_URL}#{path}"
        req_num = req_num()
        log_request('PUT', req_num, dest, data)

        response = @client.put(dest, {}, JSON.dump(data))

        log_response(response, req_num)
        register_redactions_from_response(response)
        response
      end
    end

    def delete(path)
      Async do
        dest = "#{BASE_URL}#{path}"
        req_num = req_num()
        log_request('DELETE', req_num, dest)

        response = @client.delete(dest)

        log_response(response, req_num)
        register_redactions_from_response(response)
        response
      end
    end

    def register_redactions_from_response(response)
      # Implement the redaction logic here
    end
  end
end
