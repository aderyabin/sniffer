# frozen_string_literal: true

module Sniffer
  module Adapters
    # Curl adapter
    module CurlAdapter
      def self.included(base)
        base.class_eval do
          alias_method :http_without_sniffer, :http
          alias_method :http, :http_with_sniffer

          alias_method :http_post_without_sniffer, :http_post
          alias_method :http_post, :http_post_with_sniffer
        end
      end

      def http_with_sniffer(verb)
        sniffer_request(verb)

        http_without_sniffer(verb)

        bm = Benchmark.realtime do
          @res = http_without_sniffer(verb)
        end

        sniffer_response(bm)

        @res
      end

      def http_post_with_sniffer(*args)
        sniffer_request(:POST, *args)

        bm = Benchmark.realtime do
          @res = http_post_without_sniffer(*args)
        end

        sniffer_response(bm)

        @res
      end

      private

      def data_item
        @data_item ||= Sniffer::DataItem.new if Sniffer.enabled?
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def sniffer_request(verb, *args)
        return unless data_item

        uri = URI(url)
        query = uri.path
        query += "?#{uri.query}" if uri.query

        data_item.request = Sniffer::DataItem::Request.new(host: uri.host,
                                                           method: verb,
                                                           query: query,
                                                           headers: headers.collect.to_h,
                                                           body: args.join("&"),
                                                           port: uri.port)

        Sniffer.store(data_item)
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def sniffer_response(timing)
        return unless data_item

        _, *http_headers = header_str.split(/[\r\n]+/).map(&:strip)
        http_headers = Hash[http_headers.flat_map { |s| s.scan(/^(\S+): (.+)/) }]

        data_item.response = Sniffer::DataItem::Response.new(status: status.to_i,
                                                             headers: http_headers,
                                                             body: body_str,
                                                             timing: timing)

        Sniffer.notify_response(data_item)
      end
    end
  end
end

Curl::Easy.include Sniffer::Adapters::CurlAdapter if defined?(::Curl::Easy)
