# frozen_string_literal: true
module Sniffer
  module Adapters
    # HttpClient adapter
    module HTTPClientAdapter
      def self.included(base)
        base.class_eval do
          alias_method :do_get_block_without_sniffer, :do_get_block
          alias_method :do_get_block, :do_get_block_with_sniffer
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def do_get_block_with_sniffer(req, proxy, conn, &block)
        if Sniffer.enabled?
          data_item = Sniffer::DataItem.new
          data_item.request = Sniffer::DataItem::Request.new.tap do |r|
            r.url = req.header.request_uri
            r.method = req.header.request_method
            r.headers = req.headers
            r.body = req.body
          end

          Sniffer.store(data_item)
        end

        do_get_block_without_sniffer(req, proxy, conn, &block)

        if Sniffer.enabled?
          data_item.response = Sniffer::DataItem::Response.new.tap do |r|
            r.status = @response.code.to_i
            r.headers = @response.each_header.collect.to_h
            r.body = @response.body
          end

          data_item.log
        end

        @response
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    end
  end
end
Net::HTTP.send(:include, Sniffer::Adapters::HTTPClientAdapter) if defined?(::HTTPClient)
