# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::DataItemLogger do
  let(:config) { Sniffer::Config.new }
  let(:data_item_logger) { described_class.new(config) }
  let(:logger) { config.logger }
  let(:data_item) do
    Sniffer::DataItem.new(
      request: Sniffer::DataItem::Request.new(request),
      response: Sniffer::DataItem::Response.new(response)
    )
  end

  after { data_item_logger.log(data_item) }

  describe "#log" do
    let(:request) { {} }
    let(:response) { {} }

    context 'data_item is empty' do
      let(:logified) do
        {
          port: nil, host: nil, query: nil, method: nil, request_body: nil,
          status: nil, timing: nil, response_body: nil
        }
      end

      it do
        expect(logger).to receive(:log).with(config.severity, logified.to_json)
      end
    end

    context 'config.log is null' do
      it do
        config.log = nil
        expect(logger).not_to receive(:log)
      end
    end

    context 'data_item has data' do
      let(:request) do
        {
          host: 'evilmartians.com',
          query: '/',
          headers: { 'user-agent': 'Ruby' },
          body: "author=Matz",
          method: "GET",
          port: 80
        }
      end
      let(:response) do
        {
          headers: { 'user-agent': 'Ruby' },
          body: "OK",
          status: 200,
          timing: 0.0006
        }
      end
      let(:logified) do
        {
          port: 80, host: 'evilmartians.com', query: '/',
          rq_user_agent: 'Ruby', method: 'GET', request_body: 'author=Matz',
          status: 200, rs_user_agent: 'Ruby', timing: 0.0006, response_body: 'OK'
        }
      end

      context 'defult log options' do
        it do
          expect(logger).to receive(:log).with(config.severity, logified.to_json)
        end
      end

      context 'log request_url is disabled' do
        it do
          config.log['request_url'] = false
          %i(port host query).each { |key| logified.delete(key) }

          expect(logger).to receive(:log).with(config.severity, logified.to_json)
        end
      end

      context 'log request_headers is disabled' do
        it do
          config.log['request_headers'] = false
          logified.delete(:rq_user_agent)

          expect(logger).to receive(:log).with(config.severity, logified.to_json)
        end
      end

      context 'log request_body is disabled' do
        it do
          config.log['request_body'] = false
          logified.delete(:request_body)

          expect(logger).to receive(:log).with(config.severity, logified.to_json)
        end
      end

      context 'log request_method is disabled' do
        it do
          config.log['request_method'] = false
          logified.delete(:method)

          expect(logger).to receive(:log).with(config.severity, logified.to_json)
        end
      end

      context 'log response_status is disabled' do
        it do
          config.log['response_status'] = false
          logified.delete(:status)

          expect(logger).to receive(:log).with(config.severity, logified.to_json)
        end
      end

      context 'log response_headers is disabled' do
        it do
          config.log['response_headers'] = false
          logified.delete(:rs_user_agent)

          expect(logger).to receive(:log).with(config.severity, logified.to_json)
        end
      end

      context 'log response_body is disabled' do
        it do
          config.log['response_body'] = false
          logified.delete(:response_body)

          expect(logger).to receive(:log).with(config.severity, logified.to_json)
        end
      end

      context 'prints correctly if timing option is disabled' do
        it do
          config.log['timing'] = false
          logified.delete(:timing)

          expect(logger).to receive(:log).with(config.severity, logified.to_json)
        end
      end
    end
  end
end
