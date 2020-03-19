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
          uri = URI(base_url)
          data_item.request = Sniffer::DataItem::Request.new(host: uri.host,
                                                             method: action_name,
                                                             query: url,
                                                             headers: headers.dup,
                                                             body: options[:data].to_s,
                                                             port: uri.port)

          Sniffer.store(data_item)
        end

        bm = Benchmark.realtime do
          @res = request_without_sniffer(action_name, url, headers, options)
        end

        if Sniffer.enabled?
          data_item.response = Sniffer::DataItem::Response.new(status: @res.status,
                                                               headers: @res.headers,
                                                               body: @res.body.to_s,
                                                               timing: bm)

          Sniffer.notify_response(data_item)
        end

        @res
      end
      # rubocop:enable Metrics/AbcSize,Metrics/MethodLength
    end
  end
end

::Patron::Session.include Sniffer::Adapters::PatronAdapter if defined?(::Patron::Session)
