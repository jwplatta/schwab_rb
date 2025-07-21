# frozen_string_literal: true

require "json"

module SchwabRb
  class Redactor
    # Patterns for account numbers and hashes that should be redacted
    ACCOUNT_NUMBER_PATTERN = /\b\d{8,12}\b/
    ACCOUNT_HASH_PATTERN = /\b[A-Z0-9]{32}\b/

    # JSON keys that commonly contain sensitive account information
    SENSITIVE_KEYS = %w[
      accountNumber
      accountId
      accountHash
      hashValue
      encryptedId
    ].freeze

    def self.redact_url(url_string)
      return url_string unless url_string

      redacted = url_string.to_s.dup
      redacted.gsub!(ACCOUNT_NUMBER_PATTERN, "[REDACTED_ACCOUNT_NUMBER]")
      redacted.gsub!(ACCOUNT_HASH_PATTERN, "[REDACTED_ACCOUNT_HASH]")
      redacted
    end

    def self.redact_data(data)
      return data unless data

      case data
      when Hash
        redact_hash(data)
      when String
        begin
          parsed = JSON.parse(data)
          redact_data(parsed).to_json
        rescue JSON::ParserError
          redact_string(data)
        end
      else
        data
      end
    end

    def self.redact_response_body(response)
      return unless response&.respond_to?(:body)

      body = response.body
      return unless body

      begin
        if body.is_a?(String)
          parsed = JSON.parse(body)
          redact_data(parsed)
        elsif body.respond_to?(:read)
          # Handle IO-like objects
          content = body.read
          body.rewind if body.respond_to?(:rewind)
          parsed = JSON.parse(content)
          redact_data(parsed)
        else
          redact_data(body)
        end
      rescue JSON::ParserError
        # If it's not JSON, just redact as a string
        body_str = body.respond_to?(:read) ? body.read : body.to_s
        body.rewind if body.respond_to?(:rewind)
        redact_string(body_str)
      end
    end

    def self.redact_hash(hash)
      hash.each_with_object({}) do |(key, value), redacted|
        redacted[key] = if SENSITIVE_KEYS.include?(key.to_s)
                          "[REDACTED]"
        else
          case value
          when Hash
            redact_hash(value)
          when Array
            value.map { |item| redact_data(item) }
          when String
            redact_string(value)
          else
            value
          end
                        end
      end
    end

    def self.redact_string(str)
      return str unless str.is_a?(String)

      redacted = str.dup
      redacted.gsub!(ACCOUNT_NUMBER_PATTERN, "[REDACTED_ACCOUNT_NUMBER]")
      redacted.gsub!(ACCOUNT_HASH_PATTERN, "[REDACTED_ACCOUNT_HASH]")
      redacted
    end
  end
end
