# frozen_string_literal: true

module Sniffer
  module Middleware
    # Response logging build-in middleware
    class Logger
      attr_reader :logger, :severity

      def initialize(logger, severity)
        @logger = logger
        @severity = severity
      end

      def request(_data_item)
        yield
      end

      def response(data_item)
        yield

        return unless logger

        logger.log(severity, data_item.to_json)
      end
    end
  end
end
