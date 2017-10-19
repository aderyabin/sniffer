# frozen_string_literal: true

require 'net/http'

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
          data_item.request = Sniffer::DataItem::Request.new.tap do |r|
            r.url = req.path
            r.ssl = use_ssl?
            r.port = @port
            r.method = req.method
            r.headers = req.each_header.collect.to_h
            r.body = req.body
          end

          Sniffer.store(data_item)
        end

        @response = request_without_sniffer(req, body, &block)

        if started? && Sniffer.enabled?
          data_item.response = Sniffer::DataItem::Response.new.tap do |r|
            r.status = @response.code.to_i
            r.headers = @response.each_header.collect.to_h
            r.body = @response.body
          end
        end

        @response
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    end
  end
end
Net::HTTP.send(:include, Sniffer::Adapters::NetHttpAdapter)
