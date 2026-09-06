# frozen_string_literal: true

require "json"

module SchwabRb
  module Stream
    class MessageBuilder
      def initialize(customer_id, correl_id)
        @customer_id = customer_id
        @correl_id = correl_id
        @request_id = 0
      end

      def build_login(access_token, channel, function_id)
        {
          "service" => "ADMIN",
          "command" => Commands::LOGIN,
          "requestid" => next_request_id,
          "SchwabClientCustomerId" => @customer_id,
          "SchwabClientCorrelId" => @correl_id,
          "parameters" => {
            "Authorization" => access_token,
            "SchwabClientChannel" => channel,
            "SchwabClientFunctionId" => function_id
          }
        }
      end

      def build_logout
        {
          "service" => "ADMIN",
          "command" => Commands::LOGOUT,
          "requestid" => next_request_id,
          "SchwabClientCustomerId" => @customer_id,
          "SchwabClientCorrelId" => @correl_id
        }
      end

      def build_request(service, command, keys: nil, fields: nil)
        request = {
          "service" => service,
          "command" => command,
          "requestid" => next_request_id,
          "SchwabClientCustomerId" => @customer_id,
          "SchwabClientCorrelId" => @correl_id,
          "parameters" => {}
        }

        request["parameters"]["keys"] = Array(keys).join(",") if keys
        request["parameters"]["fields"] = Fields.resolve(service, fields).join(",") if fields

        request
      end

      def wrap_requests(*requests)
        { "requests" => requests.flatten }.to_json
      end

      private

      def next_request_id
        @request_id += 1
      end
    end
  end
end
