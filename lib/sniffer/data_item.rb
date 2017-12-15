# frozen_string_literal: true

require 'active_attr'
require 'json'

module Sniffer
  # Sniffer data item stores a request info
  class DataItem
    include ActiveAttr::MassAssignment
    attr_accessor :request, :response

    def to_h
      {
        request: request && request.to_h,
        response: response && response.to_h
      }
    end

    # Stores http request data
    class Request
      include ActiveAttr::MassAssignment
      attr_accessor :host, :port, :query, :method, :headers, :body

      def to_h
        {
          host: host,
          query: query,
          port: port,
          headers: headers,
          body: body,
          method: method
        }
      end
    end
    # rubocop:enable Metrics/AbcSize,Metrics/MethodLength

    # Stores http response data
    class Response
      include ActiveAttr::MassAssignment
      attr_accessor :status, :headers, :body, :timing

      def to_h
        {
          status: status,
          headers: headers,
          body: body,
          timing: timing
        }
      end
    end
  end
end
