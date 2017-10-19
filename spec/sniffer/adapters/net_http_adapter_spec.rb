# frozen_string_literal: true

require 'spec_helper'
require "net/http"
require "uri"

RSpec.describe Sniffer::Adapters::NetHttpAdapter do
  def get_request
    uri = URI.parse(Responses::GET_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.request(request)
  end

  def post_request
    uri = URI.parse(Responses::POST_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data('lang' => 'Ruby', 'author' => 'Matz')
    http.request(request)
  end

  it 'stores request if enabled', enabled: true do
    get_request
    expect(Sniffer.data).to_not be_empty
  end

  it 'stores GET request correctly', enabled: true do
    get_request
    data = Sniffer.data[0]
    expect(data.to_h).to eq(Responses.get_response)
  end

  it 'stores POST request correctly', enabled: true do
    post_request
    data = Sniffer.data[0]
    expect(data.to_h).to eq(Responses.post_response)
  end

  it 'not stores request if disabled' do
    get_request
    expect(Sniffer.data).to be_empty
  end
end
