# frozen_string_literal: true

require "sniffer"
require_relative "data_item"
require_relative "data"
require_relative "data_item_logger"

# Sniffer allows to log http requests
module Sniffer
  # Holds all the sniffer logic
  class Capture
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
