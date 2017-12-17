# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Excon do
  let(:url) { 'http://localhost:4567' }
  let(:headers) do
    {
      'accept-encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'accept' => '*/*',
      'user-agent' => 'Ruby',
      'host' => 'localhost:4567'
    }
  end
  let(:get_params) { { path: '/?lang=ruby&author=matz', headers: headers } }
  let(:post_params) { { path: '/data?lang=ruby', body: 'author=Matz' } }
  let(:json_params) do
    {
      path: '/json',
      body: { 'lang' => 'Ruby', 'author' => 'Matz' }.to_json,
      headers: { 'Content-Type' => 'application/json; charset=UTF-8' }
    }
  end
  let(:log_data) do
    "{\"port\":4567,\"host\":\"localhost\",\"query\":\"/?lang=ruby&author=matz\",\"rq_accept_encoding\":\"gzip;q=1.0,deflate;q=0.6,identity;q=0.3\",\"rq_accept\":\"*/*\",\"rq_user_agent\":\"Ruby\",\"rq_host\":\"localhost:4567\",\"method\":\"get\",\"request_body\":\"\",\"status\":200,\"rs_content_type\":\"text/html;charset=utf-8\",\"rs_x_xss_protection\":\"1; mode=block\",\"rs_x_content_type_options\":\"nosniff\",\"rs_x_frame_options\":\"SAMEORIGIN\",\"rs_content_length\":\"2\",\"timing\":0.0006,\"response_body\":\"OK\"}"
  end

  context 'by one-off request' do
    subject { described_class }
    let(:get_request) { subject.get(url, get_params) }
    let(:post_request) { subject.post(url, post_params) }
    let(:post_json) { subject.post(url, json_params) }
    let(:get_request_dynamic_params) { subject.get(url, headers: headers, query: { lang: 'ruby', author: 'matz' }) }

    it 'logs', enabled: true do
      logger = double
      Sniffer.config.logger = logger
      expect(logger).to receive(:log).with(0, log_data)
      get_request
    end

    it_behaves_like "a sniffered", 'excon'
  end

  context 'by connection' do
    subject { described_class.new(url) }
    let(:get_request) { subject.get(get_params) }
    let(:post_request) { subject.post(post_params) }
    let(:post_json) { subject.post(json_params) }
    let(:get_request_dynamic_params) { subject.get(headers: headers, query: { lang: 'ruby', author: 'matz' }) }

    it 'logs', enabled: true do
      logger = double
      Sniffer.config.logger = logger
      expect(logger).to receive(:log).with(0, log_data)
      get_request
    end

    it_behaves_like "a sniffered", 'excon'
  end
end
