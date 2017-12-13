# frozen_string_literal: true

module Sniffer
  module Adapters
    # Excon adapter
    module ExconAdapter
      def self.included(base)
        base.class_eval do
          alias_method :request_without_sniffer, :request_call
          alias_method :request_call, :request_with_sniffer
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def request_with_sniffer(datum)
        if Sniffer.enabled?
          @data_item = Sniffer::DataItem.new
          query = datum[:path] + query_string(datum)
          @data_item.request = Sniffer::DataItem::Request.new(host: datum[:host],
                                                              method: datum[:method].to_sym,
                                                              query: query,
                                                              headers: datum[:headers],
                                                              body: datum[:body].to_s,
                                                              port: datum[:port])
          Sniffer.store(@data_item)
        end

        bm = Benchmark.realtime do
          @res = request_without_sniffer(datum)
        end

        if Sniffer.enabled?
          response_for_sniffer = Excon::Response.new(response(@res)[:response])
          @data_item.response = Sniffer::DataItem::Response.new(status: response_for_sniffer.status,
                                                                headers: response_for_sniffer.headers.collect.to_h,
                                                                body: response_for_sniffer
                                                                          .body.force_encoding(Encoding::UTF_8),
                                                                timing: bm)

          @data_item.log
        end

        @res
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end

Excon::Connection.send(:include, Sniffer::Adapters::ExconAdapter) if defined?(::Excon::Connection)
