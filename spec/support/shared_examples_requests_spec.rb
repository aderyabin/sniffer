# frozen_string_literal: true

RSpec.shared_examples "a sniffered" do
  it 'stores request if enabled', enabled: true do
    get_request
    expect(Sniffer.data).to_not be_empty
  end

  it 'logs', enabled: true do
    logger = double
    Sniffer.config.logger = logger
    expect(logger).to receive(:log).with(0, "{\"url\":\"http://localhost:4567/?lang=ruby\",\"rq_accept_encoding\":\"gzip;q=1.0,deflate;q=0.6,identity;q=0.3\",\"rq_accept\":\"*/*\",\"rq_user_agent\":\"Ruby\",\"rq_host\":\"localhost:4567\",\"method\":\"GET\",\"request_body\":null,\"status\":200,\"rs_content_type\":\"text/html;charset=utf-8\",\"rs_x_xss_protection\":\"1; mode=block\",\"rs_x_content_type_options\":\"nosniff\",\"rs_x_frame_options\":\"SAMEORIGIN\",\"rs_content_length\":\"2\",\"benchmark\":0.0006,\"response_body\":\"OK\"}")
    get_request
  end

  it 'stores GET request correctly', enabled: true do
    get_request
    data = Sniffer.data[0]
    expect(data.to_h).to match_yaml_file('get_response')
  end

  it 'stores GET request with dynamic params correctly', enabled: true do
    get_request_dynamic_params
    data = Sniffer.data[0]
    expect(data.to_h).to match_yaml_file('get_response')
  end

  it 'stores POST request correctly', enabled: true do
    post_request
    expect(Sniffer.data[0].to_h).to match_yaml_file('post_response')
  end

  it 'stores JSON correctly', enabled: true do
    post_json
    expect(Sniffer.data[0].to_h).to match_yaml_file('json_response')
  end

  it 'stores Basic Auth', enabled: true do
    get_basic_auth
    expect(Sniffer.data[0].to_h).to match_yaml_file('basic_auth_response')
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
