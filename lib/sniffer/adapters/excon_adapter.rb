# frozen_string_literal: true

module Sniffer
  module Adapters
    # Excon adapter
    module ExconAdapter
      def request_with_sniffer(params = {}, &block)
        data_item = request_sniffer_before(params)

        bm = Benchmark.realtime do
          @response = request_without_sniffer(params, &block)
        end

        request_sniffer_after(params, bm, data_item)
        @response
      end

      private

      # rubocop:disable Metrics/MethodLength
      def request_sniffer_before(params)
        return unless Sniffer.enabled?

        datum = data.merge(params)
        data_item = Sniffer::DataItem.new
        data_item.request = Sniffer::DataItem::Request.new(host: datum[:host],
                                                           method: datum[:method],
                                                           query: datum[:path] + ::Excon::Utils.query_string(datum),
                                                           headers: datum[:headers] || {},
                                                           body: datum[:body].to_s,
                                                           port: datum[:port])

        Sniffer.store(data_item)

        data_item
      end
      # rubocop:enable Metrics/MethodLength

      def request_sniffer_after(_params, benchmark, data_item)
        return unless Sniffer.enabled?

        data_item.response = Sniffer::DataItem::Response.new(status: @response.status,
                                                             headers: @response.headers,
                                                             body: @response.body,
                                                             timing: benchmark)

        Sniffer.notify_response(data_item)
      end

      # Only used when prepending, see all_prepend.rb
      module Prepend
        include ExconAdapter

        def request(params = {}, &block)
          data_item = request_sniffer_before(params)

          bm = Benchmark.realtime do
            @response = super(params, &block)
          end

          request_sniffer_after(params, bm, data_item)
          @response
        end
      end
    end
  end
end

if defined?(::Excon::Connection)
  if defined?(Sniffer::Adapters::ExconAdapter::PREPEND)
    ::Excon::Connection.prepend Sniffer::Adapters::ExconAdapter::Prepend
  else
    ::Excon::Connection.class_eval do
      include Sniffer::Adapters::ExconAdapter
      alias_method :request_without_sniffer, :request
      alias_method :request, :request_with_sniffer
    end
  end
end
