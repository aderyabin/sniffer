# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventMachine do
  let(:client) { EventMachine.new }
  let(:headers) { { 'accept-encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'accept' => '*/*', 'user-agent' => 'Ruby', 'host' => 'localhost:4567' } }

  let(:get_request) {
    EventMachine.run {
      http = EventMachine::HttpRequest.new("http://localhost:4567").get query: { 'lang' => 'ruby', 'author' => 'matz' },
                                                                        head: headers
      http.callback {
        EventMachine.stop
      }
    }
  }

  let(:post_request) do
    EventMachine.run {
      http = EventMachine::HttpRequest.new("http://localhost:4567/data").post query: { 'lang' => 'ruby' }, body: 'author=Matz'
      http.callback {
        EventMachine.stop
      }
    }
  end

  let(:post_json) do
    EventMachine.run {
      http = EventMachine::HttpRequest.new("http://localhost:4567/json").post head: { 'Content-Type' => 'application/json; charset=UTF-8' },
                                                                              body: { 'lang' => 'Ruby', 'author' => 'Matz' }.to_json
      http.callback {
        EventMachine.stop
      }
    }
  end

  it 'logs', enabled: true do
    logger = double
    Sniffer.current.config.logger = logger
    expect(logger).to receive(:log).with(0, "{\"port\":4567,\"host\":\"localhost\",\"query\":\"/?lang=ruby&author=matz\",\"rq_accept_encoding\":\"gzip;q=1.0,deflate;q=0.6,identity;q=0.3\",\"rq_accept\":\"*/*\",\"rq_user_agent\":\"Ruby\",\"rq_host\":\"localhost:4567\",\"method\":\"GET\",\"request_body\":\"\",\"status\":200,\"rs_content_type\":\"text/html;charset=utf-8\",\"rs_x_xss_protection\":\"1; mode=block\",\"rs_x_content_type_options\":\"nosniff\",\"rs_x_frame_options\":\"SAMEORIGIN\",\"rs_connection\":\"close\",\"rs_content_length\":\"2\",\"timing\":0.0006,\"response_body\":\"OK\"}")
    get_request
  end

  it_behaves_like "a sniffered", 'eventmachine'
end
