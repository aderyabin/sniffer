# frozen_string_literal: true

require "logger"

require_relative "sniffer/version"
require_relative "sniffer/config"
require_relative "sniffer/data_item"
require_relative "sniffer/data"

# Sniffer allows to log http requests
module Sniffer
  class << self
    def new(options = {})
      raise ArgumentError, "Only one instance of sniffer is allowed" unless sniffers.empty?
      sniffer = Instance.new(Sniffer::Config.new(config: options))
      sniffers.push(sniffer)
      sniffer
    end

    def capture(options = {})
      sniffer = Instance.new(Sniffer::Config.new(config: options))
      sniffers.push(sniffer)
      yield if block_given?
      sniffer
    ensure
      sniffers.pop
    end

    def enabled?
      sniffers.any?(&:enabled?)
    end

    def store(data_item)
      sniffers.each do |sniffer|
        sniffer.store(data_item) if sniffer.enabled?
      end
    end

    def log(data_item)
      sniffers.each do |sniffer|
        next if !sniffer.enabled? || sniffer.logger.nil?
        sniffer.logger.log(sniffer.config.severity, sniffer.logify_data_item(data_item).to_json)
      end
    end

    def reset!
      sniffers.clear
    end

    private

    def default
      sniffers.first
    end

    def sniffers
      Thread.current[:sniffers] ||= []
    end
  end

  # Holds all the sniffer logic
  class Instance
    def initialize(config = Config.new)
      @config = config
    end

    def config
      yield @config if block_given?
      @config
    end

    def enable!
      config.enabled = true
    end

    def disable!
      config.enabled = false
    end

    def enabled?
      config.enabled
    end

    def configure
      yield(config) if block_given?
    end

    def clear!
      data.clear
    end

    def data
      @data ||= Sniffer::Data.new(self)
    end

    def store(data_item)
      data.store(data_item)
    end

    def logger
      config.logger
    end

    # rubocop:disable Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/AbcSize
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

    def logify_data_item(data_item)
      logify_request(data_item.request).merge(logify_response(data_item.response))
    end

    def log_settings
      config.log || {}
    end
  end

  private_constant :Instance
end

require_relative "sniffer/adapters/net_http_adapter"
require_relative "sniffer/adapters/httpclient_adapter"
require_relative "sniffer/adapters/http_adapter"
require_relative "sniffer/adapters/patron_adapter"
require_relative "sniffer/adapters/curb_adapter"
require_relative "sniffer/adapters/ethon_adapter"
require_relative "sniffer/adapters/eventmachine_adapter"
