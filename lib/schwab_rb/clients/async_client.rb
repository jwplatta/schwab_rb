require 'async'
require 'async/http'
require 'json'
require_relative 'base_client'

class AsyncClient < BaseClient
  BASE_URL = 'https://api.schwabapi.com'

  def initialize
    super
    @endpoint = Async::HTTP::Endpoint.parse(BASE_URL)
    @client = Async::HTTP::Client.new(@endpoint)
  end

  def close_async_session
    @client.close
  end

  def _get_request(path, params)
    Async do
      dest = "#{BASE_URL}#{path}"
      req_num = _req_num
      # @logger.debug("Req #{req_num}: GET to #{dest}, params=#{LazyLog.new { JSON.pretty_generate(params) }}")

      query = URI.encode_www_form(params)
      response = @client.get("#{dest}?#{query}")
      # _log_response(response, req_num)
      # register_redactions_from_response(response)
      response
    end
  end

  def _post_request(path, data)
    Async do
      dest = "#{BASE_URL}#{path}"
      req_num = _req_num
      # @logger.debug("Req #{req_num}: POST to #{dest}, json=#{LazyLog.new { JSON.pretty_generate(data) }}")

      response = @client.post(dest, {}, JSON.dump(data))
      # _log_response(response, req_num)
      # register_redactions_from_response(response)
      response
    end
  end

  def _put_request(path, data)
    Async do
      dest = "#{BASE_URL}#{path}"
      req_num = _req_num
      # @logger.debug("Req #{req_num}: PUT to #{dest}, json=#{LazyLog.new { JSON.pretty_generate(data) }}")

      response = @client.put(dest, {}, JSON.dump(data))
      # _log_response(response, req_num)
      # register_redactions_from_response(response)
      response
    end
  end

  def _delete_request(path)
    Async do
      dest = "#{BASE_URL}#{path}"
      req_num = _req_num
      # @logger.debug("Req #{req_num}: DELETE to #{dest}")

      response = @client.delete(dest)
      # _log_response(response, req_num)
      # register_redactions_from_response(response)
      response
    end
  end

  private

  def register_redactions_from_response(response)
    # Implement the redaction logic here
  end
end
