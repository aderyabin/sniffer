# frozen_string_literal: true

require 'net/http'
require 'benchmark'

module Sniffer
  module Adapters
    # Net::HTTP adapter
    module NetHttpAdapter
      def request_with_sniffer(req, body = nil, &block)
        data_item = request_sniffer_before(req)

        bm = Benchmark.realtime do
          @response = request_without_sniffer(req, body, &block)
        end

        request_sniffer_after(data_item, bm)

        @response
      end

      private

      def request_sniffer_before(req)
        return unless started? && Sniffer.enabled?

        data_item = Sniffer::DataItem.new
        data_item.request = Sniffer::DataItem::Request.new(host: @address,
                                                           method: req.method,
                                                           query: req.path,
                                                           port: @port,
                                                           headers: req.each_header.collect.to_h,
                                                           body: req.body.to_s)

        Sniffer.store(data_item)

        data_item
      end

      def request_sniffer_after(data_item, benchmark)
        return unless started? && Sniffer.enabled?

        data_item.response = Sniffer::DataItem::Response.new(status: @response.code.to_i,
                                                             headers: @response.each_header.collect.to_h,
                                                             body: @response.body.to_s,
                                                             timing: benchmark)

        Sniffer.notify_response(data_item)
      end

      # Only used when prepending, see all_prepend.rb
      module Prepend
        include NetHttpAdapter

        def request(req, body = nil, &block)
          data_item = request_sniffer_before(req)

          bm = Benchmark.realtime do
            @response = super(req, body, &block)
          end

          request_sniffer_after(data_item, bm)

          @response
        end
      end
    end
  end
end

if defined?(::Net::HTTP)
  if defined?(Sniffer::Adapters::NetHttpAdapter::PREPEND)
    Net::HTTP.prepend Sniffer::Adapters::NetHttpAdapter::Prepend
  else
    Net::HTTP.class_eval do
      include Sniffer::Adapters::NetHttpAdapter
      alias_method :request_without_sniffer, :request
      alias_method :request, :request_with_sniffer
    end
  end
end
