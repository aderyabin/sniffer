# frozen_string_literal: true

module Sniffer
  module Adapters
    # HTTP adapter
    module HTTPAdapter
      def self.included(base)
        base.class_eval do
          alias_method :request_without_sniffer, :request
          alias_method :request, :request_with_sniffer
        end
      end

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
                                                             body: body.to_s,
                                                             port: uri.port)

          Sniffer.store(data_item)
        end

        bm = Benchmark.realtime do
          @res = perform(req, opts)
        end

        if Sniffer.enabled?
          data_item.response = Sniffer::DataItem::Response.new(status: @res.code,
                                                               headers: @res.headers.collect.to_h,
                                                               body: @res.body.to_s,
                                                               timing: bm)

          data_item.log
        end

        return @res unless opts.follow

        HTTP::Redirector.new(opts.follow).perform(req, @res) do |request|
          perform(request, opts)
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    end
  end
end

HTTP::Client.send(:include, Sniffer::Adapters::HTTPAdapter) if defined?(::HTTP::Client)
