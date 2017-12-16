# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sniffer do
  it "has a version number" do
    expect(Sniffer::VERSION).not_to be nil
  end

  describe ".disable!" do
    it 'disables sniffer' do
      sniffer = Sniffer.new
      sniffer.enable!
      expect {
        sniffer.disable!
      }.to change { sniffer.enabled? }.to(false)
    end
  end

  describe ".enable!" do
    it 'enables sniffer' do
      sniffer = Sniffer.new
      expect {
        sniffer.enable!
      }.to change { sniffer.enabled? }.to(true)
    end
  end

  describe ".data" do
    it "is empty by default" do
      sniffer = Sniffer.new
      expect(sniffer.data).to be_empty
    end
  end

  describe ".store" do
    it 'stores data items' do
      sniffer = Sniffer.new
      data_item = Sniffer::DataItem.new
      expect {
        sniffer.store(data_item)
      }.to change { sniffer.data.include?(data_item) }.to(true)
    end

    it 'stores no more than capacity if set (and rotate by default)' do
      sniffer = Sniffer.new
      sniffer.config.store = { capacity: 1 }

      first = Sniffer::DataItem.new
      sniffer.store(first)
      expect(sniffer.data.include?(first)).to be_truthy

      second = Sniffer::DataItem.new
      sniffer.store(second)
      expect(sniffer.data.include?(first)).to be_falsey
      expect(sniffer.data.include?(second)).to be_truthy
    end

    it 'do not stores data without rotation' do
      sniffer = Sniffer.new
      sniffer.config.store = { capacity: 1, rotate: false }

      first = Sniffer::DataItem.new
      sniffer.store(first)
      second = Sniffer::DataItem.new
      sniffer.store(second)

      expect(sniffer.data.include?(first)).to be_truthy
      expect(sniffer.data.include?(second)).to be_falsey
    end
  end

  context ".clear!" do
    sniffer = Sniffer.new
    it 'clears data' do
      sniffer.store(Sniffer::DataItem.new)

      expect {
        sniffer.clear!
      }.to change { sniffer.data.empty? }.to(true)
    end
  end

  context "config" do
    it 'is configurable' do
      sniffer = Sniffer.new
      expect {
        sniffer.config.enabled = true
      }.to change { sniffer.config.enabled }.from(false).to(true)
    end

    it 'is configurable with block' do
      sniffer = Sniffer.new
      expect {
        sniffer.config do |c|
          c.enabled = true
        end
      }.to change { sniffer.config.enabled }.from(false).to(true)
    end
  end

  it 'theadsafe' do
    expect do
      Thread.new do
        Sniffer.new.enable!
        expect(Sniffer.enabled?).to be_truthy
      end.join
    end.not_to change { Sniffer.enabled? }
  end

  context 'capture' do
    it do
      sniffer = Sniffer.new(enabled: true)

      item = Sniffer::DataItem.new
      Sniffer.store(item)

      captured_item = Sniffer::DataItem.new
      nested_captured_item = Sniffer::DataItem.new
      nested = nil
      captured = Sniffer.capture(enabled: true) do
        Sniffer.store(captured_item)
        nested = Sniffer.capture(enabled: true) do
          Sniffer.store(nested_captured_item)
        end
      end

      expect(sniffer.data).to eq [item, captured_item, nested_captured_item]
      expect(captured.data).to eq [captured_item, nested_captured_item]
      expect(nested.data).to eq [nested_captured_item]
    end
  end
end
