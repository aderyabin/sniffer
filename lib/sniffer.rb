# frozen_string_literal: true

require "logger"

require_relative "sniffer/version"
require_relative "sniffer/config"
require_relative "sniffer/data_item"

# Sniffer allows to log http requests
module Sniffer
  @data = []

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
      return unless config.store

      if config.rotate?
        rotate(data_item)
      else
        push(data_item) unless overflow?
      end
    end

    def logger
      config.logger
    end

    private

    def rotate(data_item)
      @data.shift if overflow?
      push(data_item)
    end

    def push(data_item)
      @data.push(data_item)
    end

    def overflow?
      config.capacity? && @data.length >= config.capacity
    end
  end
end

require_relative "sniffer/adapters/net_http_adapter"
require_relative "sniffer/adapters/httpclient_adapter"
require_relative "sniffer/adapters/http_adapter"
require_relative "sniffer/adapters/patron_adapter"
require_relative "sniffer/adapters/curb_adapter"
require_relative "sniffer/adapters/ethon_adapter"
