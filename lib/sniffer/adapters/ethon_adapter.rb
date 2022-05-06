# frozen_string_literal: true

module Sniffer
  module Adapters
    # Ethon adapter
    module EthonAdapter
      # overrides http_request method
      module Http
        def http_request_with_sniffer(url, action_name, options = {})
          make_sniffer_request(url, action_name, options)

          http_request_without_sniffer(url, action_name, options)
        end

        private

        def make_sniffer_request(url, action_name, options)
          return unless Sniffer.enabled?

          @data_item = Sniffer::DataItem.new
          uri = URI("http://#{url}")

          @data_item.request = Sniffer::DataItem::Request.new(host: uri.host,
                                                              method: action_name.upcase,
                                                              port: options[:port] || uri.port,
                                                              headers: options[:headers].to_h,
                                                              body: options[:body].to_s)

          Sniffer.store(@data_item)
        end

        # Only used when prepending, see all_prepend.rb
        module Prepend
          include Http

          def http_request(url, action_name, options = {})
            make_sniffer_request(url, action_name, options)

            super(url, action_name, options)
          end
        end
      end

      # overrides perform method
      module Operations
        # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        def perform_with_sniffer
          bm = Benchmark.realtime do
            @return_code = Ethon::Curl.easy_perform(handle)
          end

          if Sniffer.enabled?
            uri = URI("http://#{@url}")
            query = uri.path
            query += "?#{uri.query}" if uri.query
            @data_item.request.query = query

            status = @response_headers.scan(%r{HTTP/... (\d{3})}).flatten[0].to_i
            hash_headers = @response_headers
                           .split(/\r?\n/)[1..-1]
                           .each_with_object({}) do |item, res|
              k, v = item.split(": ")
              res[k] = v
            end

            @data_item.response = Sniffer::DataItem::Response.new(status: status,
                                                                  headers: hash_headers,
                                                                  body: @response_body,
                                                                  timing: bm)
            Sniffer.notify_response(@data_item)

          end

          Ethon.logger.debug { "ETHON: performed #{log_inspect}" } if Ethon.logger.debug?
          complete

          @return_code
        end
        # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

        # Only used when prepending, see all_prepend.rb
        module Prepend
          include Operations

          def perform
            perform_with_sniffer
          end
        end
      end
    end
  end
end

if defined?(::Ethon::Easy)
  if defined?(Sniffer::Adapters::EthonAdapter::PREPEND)
    Ethon::Easy.prepend Sniffer::Adapters::EthonAdapter::Http::Prepend
    Ethon::Easy.prepend Sniffer::Adapters::EthonAdapter::Operations::Prepend
  else
    Ethon::Easy.class_eval do
      include Sniffer::Adapters::EthonAdapter::Http
      alias_method :http_request_without_sniffer, :http_request
      alias_method :http_request, :http_request_with_sniffer

      include Sniffer::Adapters::EthonAdapter::Operations
      alias_method :perform_without_sniffer, :perform
      alias_method :perform, :perform_with_sniffer
    end
  end
end
