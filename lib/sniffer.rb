# frozen_string_literal: true

require "logger"

require_relative "sniffer/version"
require_relative "sniffer/capture"
require_relative "sniffer/config"

# Sniffer allows to log http requests
module Sniffer
  class << self
    def new(options = {})
      raise ArgumentError, "Only one instance is allowed" unless captures.empty?
      capture = Capture.new(Sniffer::Config.new(overrides: options))
      captures.push(capture)
      capture
    end

    def capture(options = {})
      capture = Capture.new(Sniffer::Config.new(overrides: options))
      captures.push(capture)
      yield if block_given?
      capture
    ensure
      captures.pop
    end

    def enabled?
      captures.any?(&:enabled?)
    end

    def store(data_item)
      captures.each do |capture|
        capture.store(data_item) if capture.enabled?
      end
    end

    def log(data_item)
      captures.each do |capture|
        next unless capture.enabled?
        capture.logger.log(data_item)
      end
    end

    def reset!
      captures.clear
    end

    private

    def default
      captures.first
    end

    def captures
      Thread.current[:captures] ||= []
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
