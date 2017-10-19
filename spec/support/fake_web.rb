# frozen_string_literal: true

require 'sinatra/base'

module FakeWeb
  class App < Sinatra::Base
    get '/' do
      [200, { "content-length" => "2" }, "OK"]
    end

    post "/data" do
      [201, { "content-length" => "7" }, "Created"]
    end
  end
end
