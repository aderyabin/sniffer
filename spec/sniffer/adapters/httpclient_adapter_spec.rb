# frozen_string_literal: true

require 'spec_helper'
require "httpclient"
require "jsonclient"
require 'base64'

RSpec.describe HTTPClient do
  let(:client) { HTTPClient.new }
  let(:headers) { { "accept-encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "accept" => "*/*", "user-agent" => "Ruby", "host" => "localhost:4567" } }
  let(:get_request) { client.get_content(URI('http://localhost:4567/?lang=ruby&author=matz'), {}, headers) }

  def get_request_dynamic_params
    uri = URI('http://localhost:4567/?lang=ruby')
    query = { author: 'matz' }
    client.get(uri, query, headers)
  end

  def post_request
    uri = URI('http://localhost:4567/data?lang=ruby')
    client.post(uri, 'author' => 'Matz')
  end

  def post_json
    uri = URI('http://localhost:4567/json')
    JSONClient.new.post(uri, 'lang' => 'Ruby', 'author' => 'Matz')
  end

  def get_basic_auth
    auth = "Basic #{Base64.strict_encode64('username:password')}"
    client.get('http://localhost:4567/', {}, 'Authorization' => auth)
  end

  it 'logs', enabled: true do
    logger = double
    Sniffer.config.logger = logger
    expect(logger).to receive(:log).with(0, "{\"port\":4567,\"host\":\"localhost\",\"query\":\"/?lang=ruby&author=matz&\",\"rq_accept_encoding\":\"gzip;q=1.0,deflate;q=0.6,identity;q=0.3\",\"rq_accept\":\"*/*\",\"rq_user_agent\":\"Ruby\",\"rq_host\":\"localhost:4567\",\"method\":\"GET\",\"request_body\":\"\",\"status\":200,\"rs_content_type\":\"text/html;charset=utf-8\",\"rs_x_xss_protection\":\"1; mode=block\",\"rs_x_content_type_options\":\"nosniff\",\"rs_x_frame_options\":\"SAMEORIGIN\",\"rs_content_length\":\"2\",\"benchmark\":0.0006,\"response_body\":\"OK\"}")
    get_request
  end

  it_behaves_like "a sniffered", 'httpclient'
end
