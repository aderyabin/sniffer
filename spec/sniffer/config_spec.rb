# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::Config do
  subject(:config) { Sniffer.config }

  it "loads default values", :aggregate_failures do
    expect(config.request_headers).to be_falsey
    expect(config.requst_body).to be_truthy
    expect(config.response_status).to be_truthy
    expect(config.response_headers).to be_falsey
    expect(config.response_body).to be_truthy
    expect(config.whitelist_url).to eq(/.*/)
    expect(config.blacklist_url).to be_nil
  end

  it 'overrides a value' do
    expect {
      config.request_headers = true
    }.to change { config.request_headers }.from(false).to(true)
  end
end
