# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::DataItem do
  it 'empty by default' do
    expect(described_class.new.to_h).to eq(request: nil, response: nil)
  end

  context "#to_log" do
    it 'returns {} if logger disabled' do
      subject.request = Sniffer::DataItem::Request.new
      subject.response = Sniffer::DataItem::Response.new
      expect(subject.to_log).to(
        eq(
          port: nil,
          host: nil,
          query: nil,
          method: nil,
          request_body: nil,
          status: nil,
          timing: nil,
          response_body: nil
        )
      )
    end

    it 'returns {} if request and response are nil' do
      expect(subject.to_log).to eq({})
    end
  end
end
