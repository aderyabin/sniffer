# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer do
  let(:klass) do
    Class.new do
      def call(data_item)
        data_item.request.host = "modified.host"

        yield
      end
    end
  end
  let(:request) do
    Sniffer::DataItem::Request.new(
      host: 'sample.host', port: 80, query: '/', method: :get, headers: {}, body: ''
    )
  end
  let(:data_item) { Sniffer::DataItem.new(request: request) }

  before do
    Sniffer.config.middleware { |chain| chain.add klass }
    Sniffer.store(data_item)
  end

  it 'logs the modified request' do
    expect(Sniffer.data.last.request.host).to eq 'modified.host'
  end

  after do
    Sniffer.config.middleware { |chain| chain.remove klass }
  end
end
