# frozen_string_literal: true

require "anyway_config"

module Sniffer
  # Sniffer configuration
  class Config < Anyway::Config
    config_name :sniffer

    attr_config logger: Logger.new($stdout),
                request_headers: false,
                requst_body: true,
                response_status: true,
                response_headers: false,
                response_body: true,
                whitelist_url:  /.*/,
                blacklist_url: nil,
                store: true,
                enabled: false
  end
end
