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
    expect(config.log['benchmark']).to be_truthy
    expect(config.store).to be_truthy
    expect(config.enabled).to be_falsey
  end

  it 'overrides a value' do
    expect {
      config.log['request_headers'] = false
    }.to change { config.log['request_headers'] }.from(true).to(false)
  end
end
