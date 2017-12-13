# frozen_string_literal: true

require "logger"

require_relative "sniffer/version"
require_relative "sniffer/config"
require_relative "sniffer/data_item"
require_relative "sniffer/data"

# Sniffer allows to log http requests
module Sniffer
  extend Forwardable
  def_delegator :current, :config, :enable!, :disable!, :enabled?, :clear!, :reset!, :data, :store, :logger, :configure
  class << self
    def current
      Thread.current[:sniffer] ||= Controller.new
    end
  end
  class Controller
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
end

require_relative "sniffer/adapters/net_http_adapter"
require_relative "sniffer/adapters/httpclient_adapter"
require_relative "sniffer/adapters/http_adapter"
require_relative "sniffer/adapters/patron_adapter"
require_relative "sniffer/adapters/curb_adapter"
require_relative "sniffer/adapters/ethon_adapter"
require_relative "sniffer/adapters/eventmachine_adapter"
