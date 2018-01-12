# frozen_string_literal: true

module Sniffer
  # match request with white and black lists
  module RequestPolicy
    class << self
      def call(request)
        url = "#{request.host}:#{request.port}"
        if config.url_whitelist
          whitelist_url?(url)
        elsif config.url_blacklist
          !blacklist_url?(url)
        else
          true
        end
      end

      private

      def whitelist_url?(url)
        !url.match(config.url_whitelist).nil?
      end

      def blacklist_url?(url)
        !url.match(config.url_blacklist).nil?
      end

      def config
        Sniffer.config
      end
    end
  end
end
