# frozen_string_literal: true

RSpec.shared_examples "a sniffered" do |fldr|
  let(:data_first_item) { Sniffer.data.first }

  it 'stores request if enabled', enabled: true do
    get_request
    expect(Sniffer.data).to_not be_empty
  end

  it 'stores GET request correctly', enabled: true do
    get_request
    expect(data_first_item.to_h).to match_yaml_file("#{fldr}/get_response")
  end

  it 'stores GET request with dynamic params correctly', enabled: true do
    skip "Not implemented in adapter" unless respond_to?(:get_request_dynamic_params)
    get_request_dynamic_params
    expect(data_first_item.to_h).to match_yaml_file("#{fldr}/get_response_dynamic")
  end

  it 'stores POST request correctly', enabled: true do
    post_request
    expect(data_first_item.to_h).to match_yaml_file("#{fldr}/post_response")
  end

  it 'stores JSON correctly', enabled: true do
    post_json
    expect(data_first_item.to_h).to match_yaml_file("#{fldr}/json_response")
  end

  it 'not stores request if disabled' do
    get_request
    expect(Sniffer.data).to be_empty
  end

  it 'not stores if storage disabled', enabled: true do
    Sniffer.config.store = false
    get_request
    expect(Sniffer.data).to be_empty
  end
end
