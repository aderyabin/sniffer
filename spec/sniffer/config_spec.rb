# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::Config do
  subject(:config) { Sniffer.config }

  it "loads default values", :aggregate_failures do
    expect(config.log_request_headers).to be_truthy
    expect(config.log_request_body).to be_truthy
    expect(config.log_response_status).to be_truthy
    expect(config.log_response_headers).to be_truthy
    expect(config.log_response_body).to be_truthy
    expect(config.whitelist_url).to eq(/.*/)
    expect(config.blacklist_url).to be_nil
    expect(config.store).to be_truthy
    expect(config.enabled).to be_falsey
  end

  it 'overrides a value' do
    expect {
      config.log_request_headers = false
    }.to change { config.log_request_headers }.from(true).to(false)
  end
end
