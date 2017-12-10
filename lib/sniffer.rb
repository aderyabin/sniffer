# frozen_string_literal: true

require "logger"

require_relative "sniffer/version"
require_relative "sniffer/config"
require_relative "sniffer/data_item"

# Sniffer allows to log http requests
module Sniffer
  @data = Set.new

  class << self
    attr_reader :data

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
      data.clear
    end

    def reset!
      @config = Config.new
      clear!
    end

    def store(data_item)
      @data.add(data_item) if config.store
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
require_relative "sniffer/adapters/curb_adapter"
require_relative "sniffer/adapters/ethon_adapter"
require_relative "sniffer/adapters/eventmachine_adapter"
