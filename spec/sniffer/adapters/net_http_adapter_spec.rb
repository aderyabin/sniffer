# frozen_string_literal: true

require 'spec_helper'
require "net/http"
require "uri"
require "json"

RSpec.describe Net::HTTP do
  def get_request
    uri = URI.parse('http://localhost:4567/')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    http.request(request)
  end

  def post_request
    uri = URI.parse('http://localhost:4567/data')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data('lang' => 'Ruby', 'author' => 'Matz')
    http.request(request)
  end

  def post_json
    uri = URI.parse('http://localhost:4567/json')
    header = { 'Content-Type' => 'text/json' }
    hash = { user: { name: 'Andrey', email: 'aderyabin@evilmartians.com' } }
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = hash.to_json
    http.request(request)
  end

  def get_basic_auth
    uri = URI.parse('http://localhost:4567/')
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth("username", "password")
    http.request(request)
  end

  it_behaves_like "a sniffered"
end
