# frozen_string_literal: true

require "logger"

require "sniffer/version"
require "sniffer/config"

# Sniffer allows to log http requests
module Sniffer
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield(config) if block_given?
    end
  end
end
