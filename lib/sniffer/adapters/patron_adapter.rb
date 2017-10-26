# frozen_string_literal: true

module Sniffer
  module Adapters
    # HTTP adapter
    module PatronAdapter
      def self.included(base)
        base.class_eval do
          alias_method :request_without_sniffer, :request
          alias_method :request, :request_with_sniffer
        end
      end

      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      def request_with_sniffer(action_name, url, headers, options = {})
        if Sniffer.enabled?
          data_item = Sniffer::DataItem.new
          data_item.request = Sniffer::DataItem::Request.new.tap do |r|
            uri = URI(base_url)
            r.host = uri.host
            r.method = action_name
            r.query = url
            r.headers = headers.dup
            r.body = options[:data].to_s
            r.port = uri.port
          end
          Sniffer.store(data_item)
        end

        bm = Benchmark.realtime do
          @res = request_without_sniffer(action_name, url, headers, options)
        end

        if Sniffer.enabled?
          data_item.response = Sniffer::DataItem::Response.new.tap do |r|
            r.status = @res.status
            r.headers = @res.headers
            r.body = @res.body.to_s
            r.timing = bm
          end

          data_item.log
        end

        @res
      end
      # rubocop:enable Metrics/AbcSize,Metrics/MethodLength
    end
  end
end

::Patron::Session.send(:include, Sniffer::Adapters::PatronAdapter) if defined?(::Patron::Session)
