# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Net::HTTP do
  let!(:sniffer) { Sniffer.new(enabled: true) }
  def get_request
    uri = URI.parse('http://localhost:4567/?lang=ruby&author=matz')
    Net::HTTP.get(uri)
  end

  def get_request_dynamic_params
    uri = URI.parse('http://localhost:4567/')
    uri.query = URI.encode_www_form(lang: 'ruby', author: 'matz')
    Net::HTTP.get(uri)
  end

  def post_request
    uri = URI.parse('http://localhost:4567/data?lang=ruby')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data('author' => 'Matz')
    http.request(request)
  end

  def post_json
    uri = URI.parse('http://localhost:4567/json')
    hash = { 'lang' => 'Ruby', 'author' => 'Matz' }
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'text/json')
    request.body = hash.to_json
    http.request(request)
  end

  it 'logs', adapter: true do
    logger = double
    sniffer.config.logger = logger
    expect(logger).to receive(:log).with(0, "{\"port\":4567,\"host\":\"localhost\",\"query\":\"/?lang=ruby&author=matz\",\"rq_accept_encoding\":\"gzip;q=1.0,deflate;q=0.6,identity;q=0.3\",\"rq_accept\":\"*/*\",\"rq_user_agent\":\"Ruby\",\"rq_host\":\"localhost:4567\",\"method\":\"GET\",\"request_body\":\"\",\"status\":200,\"rs_content_type\":\"text/html;charset=utf-8\",\"rs_x_xss_protection\":\"1; mode=block\",\"rs_x_content_type_options\":\"nosniff\",\"rs_x_frame_options\":\"SAMEORIGIN\",\"rs_content_length\":\"2\",\"timing\":0.0006,\"response_body\":\"OK\"}")
    get_request
  end

  it_behaves_like "a sniffered", 'net_http'
end
