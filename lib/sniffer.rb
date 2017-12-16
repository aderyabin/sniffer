# frozen_string_literal: true

require "logger"

require_relative "sniffer/version"
require_relative "sniffer/config"
require_relative "sniffer/data_item"
require_relative "sniffer/data"
require_relative "sniffer/data_item_logger"

# Sniffer allows to log http requests
module Sniffer
  class << self
    def new(options = {})
      raise ArgumentError, "Only one Capture of sniffer is allowed" unless sniffers.empty?
      sniffer = Capture.new(Sniffer::Config.new(config: options))
      sniffers.push(sniffer)
      sniffer
    end

    def capture(options = {})
      sniffer = Capture.new(Sniffer::Config.new(config: options))
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
        next unless sniffer.enabled?
        sniffer.logger.log(data_item)
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
  class Capture
    attr_reader :config
    def initialize(config)
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
      @logger ||= DataItemLogger.new(config)
    end
  end

  private_constant :Capture
end

require_relative "sniffer/adapters/net_http_adapter"
require_relative "sniffer/adapters/httpclient_adapter"
require_relative "sniffer/adapters/http_adapter"
require_relative "sniffer/adapters/patron_adapter"
require_relative "sniffer/adapters/curb_adapter"
require_relative "sniffer/adapters/ethon_adapter"
require_relative "sniffer/adapters/eventmachine_adapter"
