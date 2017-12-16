# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::DataItem do
  it 'empty by default' do
    expect(described_class.new.to_h).to eq(request: nil, response: nil)
  end
end
