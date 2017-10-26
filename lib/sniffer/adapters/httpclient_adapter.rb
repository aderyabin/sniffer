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

      # private

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def do_get_block_with_sniffer(req, proxy, conn, &block)
        if Sniffer.enabled?
          data_item = Sniffer::DataItem.new
          data_item.request = Sniffer::DataItem::Request.new.tap do |r|
            r.host = req.header.request_uri.host
            r.query = req.header.create_query_uri
            r.method = req.header.request_method
            r.headers = req.headers
            r.body = req.body
            r.port = req.header.request_uri.port
          end

          p data_item.request.to_h

          Sniffer.store(data_item)
        end

        retryable_response = nil

        bm = Benchmark.realtime do
          begin
            do_get_block_without_sniffer(req, proxy, conn, &block)
          rescue HTTPClient::RetryableResponse => e
            retryable_response = e
          end
        end

        if Sniffer.enabled?
          res = conn.pop
          data_item.response = Sniffer::DataItem::Response.new.tap do |r|
            r.status = res.status_code.to_i
            r.headers = res.headers
            r.body = res.body
            r.benchmark = bm
          end
          conn.push(res)

          data_item.log
        end

        raise retryable_response unless retryable_response.nil?
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    end
  end
end

HTTPClient.send(:include, Sniffer::Adapters::HTTPClientAdapter) if defined?(::HTTPClient)
