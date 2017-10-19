# frozen_string_literal: true

require "logger"

require "sniffer/version"
require "sniffer/config"
require "sniffer/data_item"

# Sniffer allows to log http requests
module Sniffer
  class << self
    def config
      @config ||= Config.new
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
      data
      @data << data_item
    end
  end
end

require "sniffer/adapters/net_http_adapter"
