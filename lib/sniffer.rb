# frozen_string_literal: true

require "logger"

require_relative "sniffer/version"
require_relative "sniffer/config"
require_relative "sniffer/data_item"
require_relative "sniffer/data"

# Sniffer allows to log http requests
module Sniffer
  class << self
    def config
      @config ||= Config.new
      yield @config if block_given?
      @config
    end

    def enable!
      Thread.current[:sniffer] = true
    end

    def disable!
      Thread.current[:sniffer] = false
    end

    def enabled?
      Thread.current[:sniffer] = config.enabled if Thread.current[:sniffer].nil?
      !!Thread.current[:sniffer]
    end

    def configure
      yield(config) if block_given?
    end

    def clear!
      data.clear
    end

    def reset!
      @config = Config.new
      Thread.current[:sniffer] = config.enabled
      clear!
    end

    def data
      @data ||= Sniffer::Data.new
    end

    def store(data_item)
      return unless config.store
      return unless data_item.allowed_to_sniff?

      config.middleware.invoke_request(data_item) do
        data.store(data_item)
      end
    end

    def notify_response(data_item)
      return unless config.store
      return unless data_item.allowed_to_sniff?

      config.middleware.invoke_response(data_item) do
      end
    end
  end
end

require_relative "sniffer/adapters/net_http_adapter"
require_relative "sniffer/adapters/httpclient_adapter"
require_relative "sniffer/adapters/http_adapter"
require_relative "sniffer/adapters/patron_adapter"
require_relative "sniffer/adapters/curb_adapter"
require_relative "sniffer/adapters/ethon_adapter"
require_relative "sniffer/adapters/eventmachine_adapter"
require_relative "sniffer/adapters/excon_adapter"
