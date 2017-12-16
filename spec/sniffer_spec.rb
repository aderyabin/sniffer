# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sniffer do
  it "has a version number" do
    expect(Sniffer::VERSION).not_to be nil
  end

  it 'theadsafe' do
    expect do
      Thread.new do
        Sniffer.new.enable!
        expect(Sniffer.enabled?).to be_truthy
      end.join
    end.not_to change { Sniffer.enabled? }
  end

  context '.capture' do
    let(:capture) { Sniffer.new(enabled: true) }

    it 'captures data' do
      item = Sniffer::DataItem.new
      capture = Sniffer.capture(enabled: true) do
        Sniffer.store(item)
      end

      expect(capture.data).to eq [item]
    end

    it 'captures data to default capture too' do
      capture

      item = Sniffer::DataItem.new
      captured = Sniffer.capture(enabled: true) do
        Sniffer.store(item)
      end

      expect(capture.data).to eq [item]
      expect(captured.data).to eq [item]
    end

    it 'captures with nesting' do
      item = Sniffer::DataItem.new

      nested_capture = nil
      capture = Sniffer.capture(enabled: true) do
        nested_capture = Sniffer.capture(enabled: true) do
          Sniffer.store(item)
        end
      end

      expect(capture.data).to eq [item]
      expect(nested_capture.data).to eq [item]
    end
  end
end
