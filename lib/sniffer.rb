# frozen_string_literal: true

require "logger"

require_relative "sniffer/version"
require_relative "sniffer/config"
require_relative "sniffer/data_item"

# Sniffer allows to log http requests
module Sniffer
  class << self
    def config
      @config ||= Config.new
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
      @data = []
    end

    def reset!
      @config = Config.new
      clear!
    end

    def data
      @data ||= []
    end

    def store(data_item)
      return unless config.store
      data
      @data << data_item
    end

    def logger
      config.logger
    end
  end
end

require_relative "sniffer/adapters/net_http_adapter"
require_relative "sniffer/adapters/httpclient_adapter"
require_relative "sniffer/adapters/http_adapter"
require_relative "sniffer/adapters/patron_adapter"
