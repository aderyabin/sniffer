# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::DataItem::Request do
  let(:sniffer) { Sniffer.new }
  subject { described_class.new(host: 'evilmartians.com', headers: { 'user-agent': 'Ruby' }, body: "author=Matz", method: "GET", port: 80) }

  context "#to_h" do
    it 'empty by default' do
      expect(described_class.new.to_h).to eq(host: nil, body: nil, method: nil, headers: nil, port: nil, query: nil)
    end

    it 'returns values' do
      expect(subject.to_h).to eq(host: "evilmartians.com", headers: { "user-agent": "Ruby" }, body: "author=Matz", method: "GET", port: 80, query: nil)
    end
  end

  context "#to_log" do
    it 'returns {} if log options is nil' do
      sniffer.config.log = nil
      expect(sniffer.logify_request(subject)).to eq({})
    end

    it 'returns nil if log options is {}' do
      sniffer.config.log = {}
      expect(sniffer.logify_request(subject)).to eq({})
    end

    it 'prints all by default', enabled: true do
      expect(sniffer.logify_request(subject)).to eq("rq_user_agent": "Ruby", method: "GET", request_body: "author=Matz", host: "evilmartians.com", query: nil, port: 80)
    end

    it 'prints correctly if request_url is disabled', enabled: true do
      sniffer.config.log["request_url"] = false
      expect(sniffer.logify_request(subject)).to eq("rq_user_agent": "Ruby", method: "GET", request_body: "author=Matz")
    end

    it 'prints correctly if request_headers option is disabled', enabled: true do
      sniffer.config.log["request_headers"] = false
      expect(sniffer.logify_request(subject)).to eq(method: "GET", request_body: "author=Matz", host: "evilmartians.com", port: 80, query: nil)
    end

    it 'prints correctly if request_body option is disabled', enabled: true do
      sniffer.config.log["request_body"] = false
      expect(sniffer.logify_request(subject)).to eq(host: "evilmartians.com", "rq_user_agent": "Ruby", method: "GET", port: 80, query: nil)
    end
  end
end
