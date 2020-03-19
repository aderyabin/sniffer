# frozen_string_literal: true

module Sniffer
  module Adapters
    # Excon adapter
    module ExconAdapter
      def self.included(base)
        base.class_eval do
          alias_method :request_without_sniffer, :request
          alias_method :request, :request_with_sniffer
        end
      end

      # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      def request_with_sniffer(params = {}, &block)
        if Sniffer.enabled?
          datum = data.merge(params)
          data_item = Sniffer::DataItem.new
          data_item.request = Sniffer::DataItem::Request.new(host: datum[:host],
                                                             method: datum[:method],
                                                             query: datum[:path] + ::Excon::Utils.query_string(datum),
                                                             headers: datum[:headers] || {},
                                                             body: datum[:body].to_s,
                                                             port: datum[:port])

          Sniffer.store(data_item)
        end

        bm = Benchmark.realtime do
          @response = request_without_sniffer(params, &block)
        end

        if Sniffer.enabled?
          data_item.response = Sniffer::DataItem::Response.new(status: @response.status,
                                                               headers: @response.headers,
                                                               body: @response.body,
                                                               timing: bm)

          Sniffer.notify_response(data_item)
        end

        @response
      end
      # rubocop:enable Metrics/AbcSize,Metrics/MethodLength
    end
  end
end

::Excon::Connection.include Sniffer::Adapters::ExconAdapter if defined?(::Excon::Connection)
