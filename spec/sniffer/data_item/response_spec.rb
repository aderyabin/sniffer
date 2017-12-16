# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::DataItem::Response do
  subject do
    described_class.new(
      headers: { 'user-agent': 'Ruby' },
      body: "OK",
      status: 200,
      timing: 0.0006
    )
  end

  context "#to_h" do
    it 'empty by default' do
      expect(described_class.new.to_h).to eq(
        status: nil,
        headers: nil,
        body: nil,
        timing: nil
      )
    end

    it 'returns values' do
      expect(subject.to_h).to eq(
        headers: { 'user-agent': "Ruby" },
        body: "OK",
        status: 200,
        timing: 0.0006
      )
    end
  end
end
