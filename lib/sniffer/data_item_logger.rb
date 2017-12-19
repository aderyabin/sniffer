# frozen_string_literal: true

module Sniffer
  # Formats data_item according to log settings and sends it to log
  class DataItemLogger
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def log(data_item)
      return if logger.nil? || config.log.nil?

      logger.log(config.severity, logify(data_item).to_json)
    end

    private

    def logger
      config.logger
    end

    def log_settings
      config.log || {}
    end

    def logify(data_item)
      logify_request(data_item.request)
        .merge!(
          logify_response(data_item.response)
        )
    end

    # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/AbcSize
    def logify_request(request)
      return {} if request.nil?
      {}.tap do |hash|
        if log_settings["request_url"]
          hash[:port] = request.port
          hash[:host] = request.host
          hash[:query] = request.query
        end

        if log_settings["request_headers"] && request.headers
          request.headers.each do |(k, v)|
            hash[:"rq_#{k.to_s.tr("-", '_').downcase}"] = v
          end
        end

        hash[:method] = request.method if log_settings["request_method"]
        hash[:request_body] = request.body if log_settings["request_body"]
      end
    end

    def logify_response(response)
      return {} if response.nil?
      {}.tap do |hash|
        hash[:status] = response.status if log_settings["response_status"]

        if log_settings["response_headers"] && response.headers
          response.headers.each do |(k, v)|
            hash[:"rs_#{k.to_s.tr("-", '_').downcase}"] = v
          end
        end

        hash[:timing] = response.timing if log_settings["timing"]
        hash[:response_body] = response.body if log_settings["response_body"]
      end
    end
    # rubocop:enable Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/AbcSize
  end
end
