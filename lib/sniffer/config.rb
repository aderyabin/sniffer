# frozen_string_literal: true

require "anyway_config"

module Sniffer
  # Sniffer configuration
  class Config < Anyway::Config
    config_name :sniffer

    attr_config logger: Logger.new($stdout),
                log_request_url: true,
                log_request_headers: true,
                log_request_body: true,
                log_request_method: true,
                log_request_port: true,
                log_request_ssl: true,
                log_response_status: true,
                log_response_headers: true,
                log_response_body: true,
                whitelist_url:  /.*/,
                blacklist_url: nil,
                store: true,
                enabled: false
  end
end
