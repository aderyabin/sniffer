# frozen_string_literal: true

module Sniffer
  module Adapters
    # HTTP adapter
    module PatronAdapter
      def request_with_sniffer(action_name, url, headers, options = {})
        data_item = request_sniffer_before(action_name, url, headers, options)

        bm = Benchmark.realtime do
          @res = request_without_sniffer(action_name, url, headers, options)
        end

        request_sniffer_after(data_item, bm)

        @res
      end

      private

      # rubocop:disable Metrics/MethodLength
      def request_sniffer_before(action_name, url, headers, options)
        return unless Sniffer.enabled?

        data_item = Sniffer::DataItem.new
        uri = URI(base_url)
        data_item.request = Sniffer::DataItem::Request.new(host: uri.host,
                                                           method: action_name,
                                                           query: url,
                                                           headers: headers.dup,
                                                           body: options[:data].to_s,
                                                           port: uri.port)

        Sniffer.store(data_item)

        data_item
      end
      # rubocop:enable Metrics/MethodLength

      def request_sniffer_after(data_item, benchmark)
        return unless Sniffer.enabled?

        data_item.response = Sniffer::DataItem::Response.new(status: @res.status,
                                                             headers: @res.headers,
                                                             body: @res.body.to_s,
                                                             timing: benchmark)

        Sniffer.notify_response(data_item)
      end

      # Only used when prepending, see all_prepend.rb
      module Prepend
        include PatronAdapter

        def request(action_name, url, headers, options = {})
          data_item = request_sniffer_before(action_name, url, headers, options)

          bm = Benchmark.realtime do
            @res = super(action_name, url, headers, options)
          end

          request_sniffer_after(data_item, bm)

          @res
        end
      end
    end
  end
end

if defined?(::Patron::Session)
  if defined?(Sniffer::Adapters::PatronAdapter::PREPEND)
    Patron::Session.prepend Sniffer::Adapters::PatronAdapter::Prepend
  else
    Patron::Session.class_eval do
      include Sniffer::Adapters::PatronAdapter
      alias_method :request_without_sniffer, :request
      alias_method :request, :request_with_sniffer
    end
  end
end
