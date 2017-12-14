# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Excon do
  let(:headers) { { "accept-encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "accept" => "*/*", "user-agent" => "Ruby", "host" => "localhost:4567" } }
  let(:get_request) do
    Excon.get('http://localhost:4567/?lang=ruby&author=matz', headers: headers)
  end

  let(:get_request_dynamic_params) do
    connection = Excon.new("http://localhost:4567/")
    connection.request(method: :get, query: { lang: :ruby, author: :matz }, headers: headers)
  end

  let(:post_request) { Excon.post('http://localhost:4567/data?lang=ruby', body: "author=Matz") }
  let(:post_json) do
    Excon.post('http://localhost:4567/json', body: { 'lang' => 'Ruby', 'author' => 'Matz' }.to_json, headers: { 'content-type' => 'application/json; charset=UTF-8' })
  end

  it 'logs', enabled: true do
    logger = double
    Sniffer.config.logger = logger
    expect(logger).to receive(:log).with(0, "{\"port\":4567,\"host\":\"localhost\",\"query\":\"?lang=ruby&author=matz\",\"rq_accept_encoding\":\"gzip;q=1.0,deflate;q=0.6,identity;q=0.3\",\"rq_accept\":\"*/*\",\"rq_user_agent\":\"Ruby\",\"rq_host\":\"localhost:4567\",\"method\":\"get\",\"request_body\":\"\",\"status\":200,\"rs_content_type\":\"text/html;charset=utf-8\",\"rs_x_xss_protection\":\"1; mode=block\",\"rs_x_content_type_options\":\"nosniff\",\"rs_x_frame_options\":\"SAMEORIGIN\",\"rs_content_length\":\"2\",\"timing\":0.0006,\"response_body\":\"OK\"}")
    get_request
  end

  it_behaves_like "a sniffered", "excon"
end
