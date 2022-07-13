# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ethon do
  let(:headers) { { "accept-encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", "accept" => "*/*", "user-agent" => "Ruby", "host" => "localhost:4567" } }
  let(:get_request) do
    easy = Ethon::Easy.new
    easy.http_request("localhost:4567/?lang=ruby&author=matz", :get, headers: headers)
    easy.perform
  end

  let(:get_request_dynamic_params) do
    easy = Ethon::Easy.new
    easy.http_request("localhost:4567/?lang=ruby", :get, params: { author: 'matz' }, headers: headers)
    easy.perform
  end

  let(:post_request) do
    easy = Ethon::Easy.new
    easy.http_request("localhost:4567/data?lang=ruby", :post, body: "author=Matz")
    easy.perform
  end
  let(:post_json) do
    easy = Ethon::Easy.new
    easy.http_request('localhost:4567/json',
                      :post,
                      headers: { 'Content-Type' => 'application/json; charset=UTF-8' },
                      body: { 'lang' => 'Ruby', 'author' => 'Matz' }.to_json)
    easy.perform
  end

  def unresolved_request
    easy = Ethon::Easy.new
    easy.http_request('localh0st:45678', :get)
    easy.perform
  end

  it 'logs', enabled: true do
    logger = double
    Sniffer.config.logger = logger
    expect(logger).to receive(:log).with(0, "{\"port\":4567,\"host\":\"localhost\",\"query\":\"/?lang=ruby&author=matz\",\"rq_accept_encoding\":\"gzip;q=1.0,deflate;q=0.6,identity;q=0.3\",\"rq_accept\":\"*/*\",\"rq_user_agent\":\"Ruby\",\"rq_host\":\"localhost:4567\",\"method\":\"GET\",\"request_body\":\"\",\"status\":200,\"rs_content_type\":\"text/html;charset=utf-8\",\"rs_x_xss_protection\":\"1; mode=block\",\"rs_x_content_type_options\":\"nosniff\",\"rs_x_frame_options\":\"SAMEORIGIN\",\"rs_content_length\":\"2\",\"timing\":0.0006,\"response_body\":\"OK\"}")
    get_request
  end

  it_behaves_like "a sniffered", 'curb'
end
