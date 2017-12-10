# frozen_string_literal: true

module Sniffer
  module Adapters
    module EventMachineAdapter
      module Client
        def self.included(base)
          base.class_eval do
            alias_method :send_request_without_sniffer, :send_request
            alias_method :send_request, :send_request_with_sniffer
            alias_method :parse_response_header_without_sniffer, :parse_response_header
            alias_method :parse_response_header, :parse_response_header_with_sniffer
            alias_method :on_body_data_without_sniffer, :on_body_data
            alias_method :on_body_data, :on_body_data_with_sniffer
          end
        end

        def send_request_with_sniffer(head, body)
          if Sniffer.enabled?
            @data_item = Sniffer::DataItem.new
            @data_item.response = Sniffer::DataItem::Response.new
            @data_item.request = Sniffer::DataItem::Request.new(host: @req.host,
                                                                method: @req.method.to_sym,
                                                                query: encode_query(@req.uri, @req.query),
                                                                headers: @req.headers,
                                                                body: @req.body.to_s,
                                                                port: @req.port)
            Sniffer.store(@data_item)

            @start_time = Time.now
          end

          send_request_without_sniffer(head, body)
        end

        def parse_response_header_with_sniffer(header, version, status)
          if Sniffer.enabled?
            @data_item.response.timing = Time.now - @start_time
            @data_item.response.status = status
            @data_item.response.headers = header
          end

          parse_response_header_without_sniffer(header, version, status)
        end

        def on_body_data_with_sniffer(data)
          if Sniffer.enabled?
            @data_item.response.body = data
            @data_item.log
          end

          on_body_data_without_sniffer(data)
        end

        def set_timing(timing)
          @data_item.response.timing = timing
        end
      end
    end
  end
end

if defined?(::EventMachine)
  EventMachine::HttpClient.send(:include, Sniffer::Adapters::EventMachineAdapter::Client)
end
