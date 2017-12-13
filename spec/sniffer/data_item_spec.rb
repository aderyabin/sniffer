# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::DataItem do
  it 'empty by default' do
    expect(described_class.new.to_h).to eq(request: nil, response: nil)
  end

  context "#to_log"
  it 'returns {} if logger disabled' do
    Sniffer.current.config.logger = false
    expect(subject.to_log).to eq({})
  end

  it 'returns {} if logger is nil' do
    Sniffer.current.config.logger = nil
    expect(subject.to_log).to eq({})
  end
end
