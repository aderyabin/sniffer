# frozen_string_literal: true

module Sniffer
  module Adapters
    module ExconAdapter
      def self.included(base)
        base.class_eval do
          middlewares = ::Excon.defaults[:middlewares]

          response_parser_index = middlewares.index(::Excon::Middleware::ResponseParser)
          middlewares.insert(response_parser_index - 1, Sniffer::Adapters::ExconAdapter::Request)
          middlewares.insert(response_parser_index + 1, Sniffer::Adapters::ExconAdapter::Response)
        end
      end

      class Request < ::Excon::Middleware::Base
        def request_call(params)
          if Sniffer.enabled?
            data_item = Sniffer::DataItem.new
            data_item.request = Sniffer::DataItem::Request.new(host: params[:host],
                                                               method: params[:method],
                                                               query: ::Excon::Utils.query_string(params),
                                                               headers: params[:headers],
                                                               body: params[:body].to_s,
                                                               port: params[:port])

            Sniffer.store(data_item)
            params[:sniffer_data_item] = data_item
          end

          super(params)
        end
      end

      class Response < ::Excon::Middleware::Base
        def response_call(params)
          if Sniffer.enabled?
            data_item = params.delete(:sniffer_data_item)
            response = params[:response]
            data_item.response = Sniffer::DataItem::Response.new(status: response[:status],
                                                                 headers: response[:headers],
                                                                 body: response[:body],
                                                                 timing: 'fake') # TODO: think about timing

            Sniffer.store(data_item)
            data_item.log
          end

          super(params)
        end
      end
    end
  end
end

Excon.send(:include, Sniffer::Adapters::ExconAdapter) if defined?(::Excon)
