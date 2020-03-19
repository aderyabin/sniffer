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
          data_item.request = Sniffer::DataItem::Request.new(host: req.header.request_uri.host,
                                                             query: req.header.create_query_uri,
                                                             method: req.header.request_method,
                                                             headers: req.headers,
                                                             body: req.body,
                                                             port: req.header.request_uri.port)

          Sniffer.store(data_item)
        end

        retryable_response = nil

        bm = Benchmark.realtime do
          do_get_block_without_sniffer(req, proxy, conn, &block)
        rescue HTTPClient::RetryableResponse => e
          retryable_response = e
        end

        if Sniffer.enabled?
          res = conn.pop
          data_item.response = Sniffer::DataItem::Response.new(status: res.status_code.to_i,
                                                               headers: res.headers,
                                                               body: res.body,
                                                               timing: bm)

          conn.push(res)

          Sniffer.notify_response(data_item)
        end

        raise retryable_response unless retryable_response.nil?
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end

HTTPClient.include Sniffer::Adapters::HTTPClientAdapter if defined?(::HTTPClient)
