# frozen_string_literal: true

require 'active_attr'

module Sniffer
  # Sniffer data item stores a request info
  class DataItem
    include ActiveAttr::MassAssignment
    attr_accessor :request, :response

    def to_h
      {
        request: request&.to_h,
        response: response&.to_h
      }
    end

    def log
      Sniffer.logger.log(Sniffer.config.severity, to_json)
    end

    def to_log
      return {} unless Sniffer.config.logger
      request.to_log.merge(response.to_log)
    end

    def to_json
      to_log.to_json
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
      attr_accessor :url, :headers, :body, :method, :port

      def to_h
        {
          url: url,
          headers: headers,
          body: body,
          method: method,
          port: port
        }
      end

      # rubocop:disable Metrics/AbcSize
      def to_log
        {}.tap do |hash|
          hash[:url] = url if log_settings["request_url"]
          if log_settings["request_headers"]
            headers.each do |(k, v)|
              hash[:"rq_#{k.to_s.tr("-", '_')}"] = v
            end
          end

          hash[:method] = method if log_settings["request_method"]
          hash[:request_body] = body if log_settings["request_body"]
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

    # Stores http response data
    class Response < HttpObject
      attr_accessor :status, :headers, :body, :benchmark

      def to_h
        {
          status: status,
          headers: headers,
          body: body,
          benchmark: benchmark
        }
      end

      # rubocop:disable Metrics/AbcSize
      def to_log
        {}.tap do |hash|
          hash[:status] = status if log_settings["response_status"]

          if log_settings["response_headers"]
            headers.each do |(k, v)|
              hash[:"rs_#{k.to_s.tr("-", '_')}"] = v
            end
          end

          hash[:benchmark] = benchmark if log_settings["benchmark"]
          hash[:response_body] = body if log_settings["response_body"]
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
