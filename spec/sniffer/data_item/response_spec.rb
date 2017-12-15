# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::DataItem::Response do
  let(:sniffer) { Sniffer.new }
  subject { described_class.new(headers: { 'user-agent': 'Ruby' }, body: "OK", status: 200, timing: 0.0006) }

  context "#to_h" do
    it 'empty by default' do
      expect(described_class.new.to_h).to eq(status: nil, headers: nil, body: nil, timing: nil)
    end

    it 'returns values' do
      expect(subject.to_h).to eq(headers: { 'user-agent': "Ruby" }, body: "OK", status: 200, timing: 0.0006)
    end
  end

  context "#to_log" do
    it 'returns {} if log options is nil' do
      sniffer.config.log = nil
      expect(sniffer.logify_response(subject)).to eq({})
    end

    it 'returns nil if log options is {}' do
      sniffer.config.log = {}
      expect(sniffer.logify_response(subject)).to eq({})
    end

    it 'prints all by default', enabled: true do
      expect(sniffer.logify_response(subject)).to eq("rs_user_agent": "Ruby", response_body: "OK", status: 200, timing: 0.0006)
    end

    it 'prints correctly if response_status is disabled', enabled: true do
      sniffer.config.log["response_status"] = false
      expect(sniffer.logify_response(subject)).to eq("rs_user_agent": "Ruby", response_body: "OK", timing: 0.0006)
    end

    it 'prints correctly if response_headers option is disabled', enabled: true do
      sniffer.config.log["response_headers"] = false
      expect(sniffer.logify_response(subject)).to eq(response_body: "OK", status: 200, timing: 0.0006)
    end

    it 'prints correctly if response_body option is disabled', enabled: true do
      sniffer.config.log["response_body"] = false
      expect(sniffer.logify_response(subject)).to eq("rs_user_agent": "Ruby", status: 200, timing: 0.0006)
    end

    it 'prints correctly if timing option is disabled', enabled: true do
      sniffer.config.log["timing"] = false
      expect(sniffer.logify_response(subject)).to eq("rs_user_agent": "Ruby", status: 200, response_body: "OK")
    end
  end
end
