# frozen_string_literal: true

require "http"
require 'spec_helper'

RSpec.describe HTTP do
  let(:headers) { { "accept-encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "accept" => "*/*", "user-agent" => "Ruby", "host" => "localhost:4567" } }
  let(:get_request) { HTTP.get('http://localhost:4567/?lang=ruby&author=matz', headers: headers) }
  let(:get_request_dynamic_params) { HTTP.get("http://localhost:4567/?lang=ruby", headers: headers, params: { author: 'matz' }) }
  let(:post_request) { HTTP.post('http://localhost:4567/data?lang=ruby', body: "author=Matz") }
  let(:post_json) { HTTP.post('http://localhost:4567/json', json: { 'lang' => 'Ruby', 'author' => 'Matz' }) }

  let(:get_basic_auth) { HTTP.basic_auth(user: "username", pass: "password").get('http://localhost:4567', headers: headers) }

  it 'logs', enabled: true do
    logger = double
    Sniffer.config.logger = logger
    expect(logger).to receive(:log).with(0, "{\"port\":4567,\"host\":\"localhost\",\"query\":\"/?lang=ruby&author=matz\",\"rq_accept_encoding\":\"gzip;q=1.0,deflate;q=0.6,identity;q=0.3\",\"rq_accept\":\"*/*\",\"rq_user_agent\":\"Ruby\",\"rq_host\":\"localhost:4567\",\"rq_connection\":\"close\",\"method\":\"get\",\"request_body\":\"\",\"status\":200,\"rs_content_type\":\"text/html;charset=utf-8\",\"rs_x_xss_protection\":\"1; mode=block\",\"rs_x_content_type_options\":\"nosniff\",\"rs_x_frame_options\":\"SAMEORIGIN\",\"rs_connection\":\"close\",\"rs_content_length\":\"2\",\"benchmark\":0.0006,\"response_body\":\"OK\"}")
    get_request
  end

  it_behaves_like "a sniffered", 'http'
end
