# frozen_string_literal: true

module Sniffer
  # Sniffer data item stores a request info
  class DataItem
    attr_accessor :request, :response

    def to_h
      {
        request: request&.to_h,
        response: response&.to_h
      }
    end

    # Stores http request data
    class Request
      attr_accessor :url, :headers, :body, :method, :ssl, :port

      def to_h
        {
          url: url,
          headers: headers,
          body: body,
          method: method,
          ssl: ssl,
          port: port
        }
      end
    end

    # Stores http response data
    class Response
      attr_accessor :status, :headers, :body

      def to_h
        {
          status: status,
          headers: headers,
          body: body
        }
      end
    end
  end
end
