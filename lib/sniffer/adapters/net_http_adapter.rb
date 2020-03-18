# frozen_string_literal: true

require 'net/http'
require 'benchmark'

module Sniffer
  module Adapters
    # Net::HTTP adapter
    module NetHttpAdapter
      def self.included(base)
        base.class_eval do
          alias_method :request_without_sniffer, :request
          alias_method :request, :request_with_sniffer
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def request_with_sniffer(req, body = nil, &block)
        if started? && Sniffer.enabled?
          data_item = Sniffer::DataItem.new
          data_item.request = Sniffer::DataItem::Request.new(host: @address,
                                                             method: req.method,
                                                             query: req.path,
                                                             port: @port,
                                                             headers: req.each_header.collect.to_h,
                                                             body: req.body.to_s)

          Sniffer.store(data_item)
        end

        bm = Benchmark.realtime do
          @response = request_without_sniffer(req, body, &block)
        end

        if started? && Sniffer.enabled?
          data_item.response = Sniffer::DataItem::Response.new(status: @response.code.to_i,
                                                               headers: @response.each_header.collect.to_h,
                                                               body: @response.body.to_s,
                                                               timing: bm)

          Sniffer.notify_response(data_item)
        end

        @response
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
Net::HTTP.include Sniffer::Adapters::NetHttpAdapter
