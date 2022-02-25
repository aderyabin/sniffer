# frozen_string_literal: true

module Sniffer
  module Adapters
    # HttpClient adapter
    module HTTPClientAdapter
      def do_get_block_with_sniffer(req, proxy, conn, &block)
        data_item = do_get_block_sniffer_before(req)

        retryable_response = nil

        bm = Benchmark.realtime do
          do_get_block_without_sniffer(req, proxy, conn, &block)
        rescue HTTPClient::RetryableResponse => e
          retryable_response = e
        end

        do_get_block_sniffer_after(data_item, conn, bm)

        raise retryable_response unless retryable_response.nil?
      end

      private

      # rubocop:disable Metrics/AbcSize
      def do_get_block_sniffer_before(req)
        return unless Sniffer.enabled?

        data_item = Sniffer::DataItem.new
        data_item.request = Sniffer::DataItem::Request.new(host: req.header.request_uri.host,
                                                           query: req.header.create_query_uri,
                                                           method: req.header.request_method,
                                                           headers: req.headers,
                                                           body: req.body,
                                                           port: req.header.request_uri.port)

        Sniffer.store(data_item)

        data_item
      end
      # rubocop:enable Metrics/AbcSize

      def do_get_block_sniffer_after(data_item, conn, benchmark)
        return unless Sniffer.enabled?

        res = conn.pop
        data_item.response = Sniffer::DataItem::Response.new(status: res.status_code.to_i,
                                                             headers: res.headers,
                                                             body: res.body,
                                                             timing: benchmark)

        conn.push(res)

        Sniffer.notify_response(data_item)
      end

      # Only used when prepending, see all_prepend.rb
      module Prepend
        include HTTPClientAdapter

        def do_get_block(req, proxy, conn, &block)
          data_item = do_get_block_sniffer_before(req)

          retryable_response = nil

          bm = Benchmark.realtime do
            super(req, proxy, conn, &block)
          rescue HTTPClient::RetryableResponse => e
            retryable_response = e
          end

          do_get_block_sniffer_after(data_item, conn, bm)

          raise retryable_response unless retryable_response.nil?
        end
      end
    end
  end
end

if defined?(::HTTPClient)
  if defined?(Sniffer::Adapters::HTTPClientAdapter::PREPEND)
    HTTPClient.prepend Sniffer::Adapters::HTTPClientAdapter::Prepend
  else
    HTTPClient.class_eval do
      include Sniffer::Adapters::HTTPClientAdapter
      alias_method :do_get_block_without_sniffer, :do_get_block
      alias_method :do_get_block, :do_get_block_with_sniffer
    end
  end
end
