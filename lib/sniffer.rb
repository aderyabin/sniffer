# frozen_string_literal: true

require "logger"

require_relative "sniffer/version"
require_relative "sniffer/config"
require_relative "sniffer/data_item"
require_relative "sniffer/data"

# Sniffer allows to log http requests
module Sniffer
  class << self
    extend Forwardable

    def capture(options = {})
      # TODO: make Anyway config to support creation with hash
      config = Sniffer::Config.new
      { enabled: true }.merge!(options).each do |k, v|
        config.send("#{k}=", v)
      end
      sniffer = Instance.new(config)
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
        sniffer.logger.log(sniffer.config.severity, data_item.to_json)
      end
    end

    private

    def default
      sniffers.first
    end
    def_delegators :default, :config, :enable!, :disable!, :clear!, :reset!, :data

    def sniffers
      Thread.current[:sniffers] ||= [Instance.new]
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

    def reset!
      @config = Config.new
      clear!
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
