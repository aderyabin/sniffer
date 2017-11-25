# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::Config do
  subject(:config) { Sniffer.config }

  it "loads default values", :aggregate_failures do
    expect(config.log['request_headers']).to be_truthy
    expect(config.log['request_body']).to be_truthy
    expect(config.log['request_method']).to be_truthy
    expect(config.log['request_url']).to be_truthy
    expect(config.log['response_status']).to be_truthy
    expect(config.log['response_headers']).to be_truthy
    expect(config.log['response_body']).to be_truthy
    expect(config.log['timing']).to be_truthy
    expect(config.store).to be_truthy
    expect(config.enabled).to be_falsey
  end

  it 'overrides a value' do
    expect {
      config.log['request_headers'] = false
    }.to change { config.log['request_headers'] }.from(true).to(false)
  end

  describe '#store' do
    it 'allows store to be a hash' do
      config.store = {}
      expect(config.store).to be_truthy
      expect(config.capacity?).to be_falsey
      expect(config.rotate?).to be_falsey
      expect { config.capacity }.to raise_error KeyError
    end

    it 'allows capacity to be set' do
      config.store = { capacity: 50 }
      expect(config.store).to be_truthy
      expect(config.capacity?).to be_truthy
      expect(config.rotate?).to be_truthy
      expect(config.capacity).to eq 50
    end

    it 'allows rotate to be set with capacity' do
      config.store = { capacity: 50, rotate: false }
      expect(config.rotate?).to be_falsey

      config.store = { capacity: 50, rotate: true }
      expect(config.rotate?).to be_truthy
    end
  end
end
