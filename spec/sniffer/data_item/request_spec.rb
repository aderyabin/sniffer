# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::DataItem::Request do
  subject do
    described_class.new(
      host: 'evilmartians.com',
      headers: { 'user-agent': 'Ruby' },
      body: "author=Matz",
      method: "GET",
      port: 80
    )
  end

  context "#to_h" do
    it 'empty by default' do
      expect(described_class.new.to_h).to eq(
        host: nil,
        body: nil,
        method: nil,
        headers: nil,
        port: nil,
        query: nil
      )
    end

    it 'returns values' do
      expect(subject.to_h).to eq(
        host: "evilmartians.com",
        headers: { "user-agent": "Ruby" },
        body: "author=Matz",
        method: "GET",
        port: 80,
        query: nil
      )
    end
  end
end
