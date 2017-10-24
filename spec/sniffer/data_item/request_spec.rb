# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::DataItem::Request do
  subject { described_class.new(url: 'http://evilmartians.com', headers: { 'user-agent': 'Ruby' }, body: "author=Matz", method: "GET", ssl: false, port: 80) }

  context "#to_h" do
    it 'empty by default' do
      expect(described_class.new.to_h).to eq(url: nil, body: nil, method: nil, headers: nil, port: nil, ssl: nil)
    end

    it 'returns values' do
      expect(subject.to_h).to eq(url: "http://evilmartians.com", headers: { "user-agent": "Ruby" }, body: "author=Matz", method: "GET", port: 80, ssl: false)
    end
  end

  context "#to_log" do
    it 'returns {} if log options is nil' do
      Sniffer.config.log = nil
      expect(subject.to_log).to eq({})
    end

    it 'returns nil if log options is {}' do
      Sniffer.config.log = {}
      expect(subject.to_log).to eq({})
    end

    it 'prints all by default', enabled: true do
      expect(subject.to_log).to eq("rq_user_agent": "Ruby", method: "GET", request_body: "author=Matz", url: "http://evilmartians.com")
    end

    it 'prints correctly if Request_url is disabled', enabled: true do
      Sniffer.config.log["request_url"] = false
      expect(subject.to_log).to eq("rq_user_agent": "Ruby", method: "GET", request_body: "author=Matz")
    end

    it 'prints correctly if request_headers option is disabled', enabled: true do
      Sniffer.config.log["request_headers"] = false
      expect(subject.to_log).to eq(method: "GET", request_body: "author=Matz", url: "http://evilmartians.com")
    end

    it 'prints correctly if request_body option is disabled', enabled: true do
      Sniffer.config.log["request_body"] = false
      expect(subject.to_log).to eq(url: "http://evilmartians.com", "rq_user_agent": "Ruby", method: "GET")
    end
  end
end
