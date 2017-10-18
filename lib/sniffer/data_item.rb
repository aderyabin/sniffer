# frozen_string_literal: true

module Sniffer
  # Sniffer data item stores a request info
  class DataItem
    attr_accessor :request_headers, :requst_body,
                  :response_status, :response_headers, :response_body
  end
end
