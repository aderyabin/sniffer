# frozen_string_literal: true

require 'active_attr'
require 'json'
require_relative 'request_policy'

module Sniffer
  # Sniffer data item stores a request info
  class DataItem
    include ActiveAttr::MassAssignment
    attr_accessor :request, :response

    def to_h
      {
        request: # frozen_string_literal: true
# Sniffer data item stores a request info
# Basic object for request and response objects
# Stores http request data
# rubocop:enable
# Stores http response data

request&.to_h,
        response: # frozen_string_literal: true
# Sniffer data item stores a request info
# Basic object for request and response objects
# Stores http request data
# rubocop:enable
# Stores http response data

response&.to_h
      }
    end

    def to_log
      return {} unless Sniffer.config.logger

      request.to_log.merge(response.to_log)
    end

    def to_json(*_args)
      to_log.to_json
    end

    def allowed_to_sniff?
      return true unless request

      RequestPolicy.call(request)
    end

    # Basic object for request and response objects
    class HttpObject
      include ActiveAttr::MassAssignment

      def log_message
        raise NotImplementedError
      end

      def log_settings
        Sniffer.config.log || {}
      end
    end

    # Stores http request data
    class Request < HttpObject
      attr_accessor :host, :port, :query, :method, :headers, :body

      def to_h
        {
          host: host,
          query: query,
          port: port,
          headers: headers,
          body: # frozen_string_literal: true
# Sniffer data item stores a request info
# Basic object for request and response objects
# Stores http request data
# rubocop:enable
# Stores http response data

body&.to_s,
          method: method
        }
      end

      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      def to_log
        {}.tap do |hash|
          if log_settings["request_url"]
            hash[:port] = port
            hash[:host] = host
            hash[:query] = query
          end

          if log_settings["request_headers"]
            headers.each do |(k, v)|
              hash[:"rq_#{k.to_s.tr("-", '_').downcase}"] = v
            end
          end

          hash[:method] = method if log_settings["request_method"]
          hash[:request_body] = body.to_s if log_settings["request_body"]
        end
      end
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

    # Stores http response data
    class Response < HttpObject
      attr_accessor :status, :headers, :body, :timing

      def to_h
        {
          status: status,
          headers: headers,
          body: # frozen_string_literal: true
# Sniffer data item stores a request info
# Basic object for request and response objects
# Stores http request data
# rubocop:enable
# Stores http response data

body&.to_s,
          timing: timing
        }
      end

      # rubocop:disable Metrics/AbcSize
      def to_log
        {}.tap do |hash|
          hash[:status] = status if log_settings["response_status"]

          if log_settings["response_headers"]
            headers.each do |(k, v)|
              hash[:"rs_#{k.to_s.tr("-", '_').downcase}"] = v
            end
          end

          hash[:timing] = timing if log_settings["timing"]
          hash[:response_body] = body.to_s if log_settings["response_body"]
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
