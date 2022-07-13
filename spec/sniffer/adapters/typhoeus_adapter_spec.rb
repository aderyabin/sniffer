# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Typhoeus do
  let(:headers) { { "accept-encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "accept" => "*/*", "user-agent" => "Ruby", "host" => "localhost:4567" } }
  let(:get_request) { Typhoeus::Request.new('localhost:4567/?lang=ruby&author=matz', method: :get, headers: headers).run }
  let(:get_request_dynamic_params) do
    Typhoeus::Request.new("localhost:4567/?lang=ruby",
                          method: :get,
                          headers: headers,
                          params: { author: 'matz' }).run
  end
  let(:post_request) { Typhoeus::Request.new('localhost:4567/data?lang=ruby', method: :post, body: "author=Matz").run }

  let(:post_json) do
    Typhoeus::Request.new('localhost:4567/json',
                          method: :post,
                          body: { 'lang' => 'Ruby', 'author' => 'Matz' }.to_json,
                          headers: { 'Content-Type' => "application/json" }).run
  end

  def unresolved_request
    Typhoeus::Request.new('localhost:45678').run
  end

  it 'logs', enabled: true do
    logger = double
    Sniffer.config.logger = logger
    expect(logger).to receive(:log).with(0, "{\"port\":4567,\"host\":\"localhost\",\"query\":\"/?lang=ruby&author=matz\",\"rq_user_agent\":\"Ruby\",\"rq_accept_encoding\":\"gzip;q=1.0,deflate;q=0.6,identity;q=0.3\",\"rq_accept\":\"*/*\",\"rq_host\":\"localhost:4567\",\"rq_expect\":\"\",\"method\":\"GET\",\"request_body\":\"\",\"status\":200,\"rs_content_type\":\"text/html;charset=utf-8\",\"rs_x_xss_protection\":\"1; mode=block\",\"rs_x_content_type_options\":\"nosniff\",\"rs_x_frame_options\":\"SAMEORIGIN\",\"rs_content_length\":\"2\",\"timing\":0.0006,\"response_body\":\"OK\"}")
    get_request
  end

  it_behaves_like "a sniffered", 'typhoeus'
end
