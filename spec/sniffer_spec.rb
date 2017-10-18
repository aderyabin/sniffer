# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sniffer do
  it "has a version number" do
    expect(Sniffer::VERSION).not_to be nil
  end

  context "data" do
    it "empty by default" do
      expect(Sniffer.data).to eq([])
    end

    context ".store" do
      it 'stores data items' do
        data_item = Sniffer::DataItem.new
        expect {
          Sniffer.store(data_item)
        }.to change { Sniffer.data }.to([data_item])
      end
    end

    context ".clear!" do
      it 'clear data' do
        Sniffer.store(Sniffer::DataItem.new)
        expect {
          Sniffer.clear!
        }.to change { Sniffer.data }.to([])
      end
    end
  end
end
