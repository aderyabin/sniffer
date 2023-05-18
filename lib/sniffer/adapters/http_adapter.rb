# frozen_string_literal: true

module Sniffer
  module Adapters
    # HTTP adapter
    module HTTPAdapter
      # private

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def request_with_sniffer(verb, uri, opts = {})
        opts    = @default_options.merge(opts)
        uri     = make_request_uri(uri, opts)
        headers = make_request_headers(opts)
        body    = make_request_body(opts, headers)
        proxy   = opts.proxy

        req = HTTP::Request.new(
          verb: verb,
          uri: uri,
          headers: headers,
          proxy: proxy,
          body: body,
          auto_deflate: opts.feature(:auto_deflate)
        )

        if Sniffer.enabled?
          data_item = Sniffer::DataItem.new
          query = uri.path
          query += "?#{uri.query}" if uri.query

          data_item.request = Sniffer::DataItem::Request.new(host: uri.host,
                                                             method: verb,
                                                             query: query,
                                                             headers: headers.collect.to_h,
                                                             body: body,
                                                             port: uri.port)

          Sniffer.store(data_item)
        end

        bm = Benchmark.realtime do
          @res = perform(req, opts)
        end

        if Sniffer.enabled?
          data_item.response = Sniffer::DataItem::Response.new(status: @res.code,
                                                               headers: @res.headers.collect.to_h,
                                                               body: @res.body,
                                                               timing: bm)

          Sniffer.notify_response(data_item)
        end

        return @res unless opts.follow

        HTTP::Redirector.new(opts.follow).perform(req, @res) do |request|
          perform(request, opts)
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      # Only used when prepending, see all_prepend.rb
      module Prepend
        include HTTPAdapter

        def request(*args)
          request_with_sniffer(*args)
        end
      end
    end
  end
end

if defined?(::HTTP::Client)
  if defined?(Sniffer::Adapters::HTTPAdapter::PREPEND)
    HTTP::Client.prepend Sniffer::Adapters::HTTPAdapter::Prepend
  else
    HTTP::Client.class_eval do
      include Sniffer::Adapters::HTTPAdapter
      alias_method :request_without_sniffer, :request
      alias_method :request, :request_with_sniffer
    end
  end
end
