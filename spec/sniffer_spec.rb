# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sniffer do
  it "has a version number" do
    expect(Sniffer::VERSION).not_to be nil
  end

  describe ".disable!" do
    it 'disables sniffer' do
      Sniffer.enable!
      expect {
        Sniffer.disable!
      }.to change { Sniffer.enabled? }.to(false)
    end
  end

  describe ".enable!" do
    it 'enables sniffer' do
      expect {
        Sniffer.enable!
      }.to change { Sniffer.enabled? }.to(true)
    end
  end

  describe ".data" do
    it "is empty by default" do
      expect(Sniffer.data).to be_empty
    end
  end

  describe ".store" do
    it 'stores data items' do
      data_item = Sniffer::DataItem.new
      expect {
        Sniffer.store(data_item)
      }.to change { Sniffer.data.include?(data_item) }.to(true)
    end

    it 'stores no more than capacity if set (and rotate by default)' do
      Sniffer.config.store = { capacity: 1 }

      first = Sniffer::DataItem.new
      Sniffer.store(first)
      expect(Sniffer.data.include?(first)).to be_truthy

      second = Sniffer::DataItem.new
      Sniffer.store(second)
      expect(Sniffer.data.include?(first)).to be_falsey
      expect(Sniffer.data.include?(second)).to be_truthy
    end

    it 'do not stores data without rotation' do
      Sniffer.config.store = { capacity: 1, rotate: false }

      first = Sniffer::DataItem.new
      Sniffer.store(first)
      second = Sniffer::DataItem.new
      Sniffer.store(second)

      expect(Sniffer.data.include?(first)).to be_truthy
      expect(Sniffer.data.include?(second)).to be_falsey
    end
  end

  describe ".allowed_to_sniff" do
    it "returns true with empty data" do
      expect(Sniffer.allowed_to_sniff?(Sniffer::DataItem.new)).to eq(true)
    end
  end

  describe ".clear!" do
    it 'clears data' do
      Sniffer.store(Sniffer::DataItem.new)

      expect {
        Sniffer.clear!
      }.to change { Sniffer.data.empty? }.to(true)
    end
  end

  context "config" do
    it 'is configurable' do
      expect {
        Sniffer.config.enabled = true
      }.to change { Sniffer.config.enabled }.from(false).to(true)
    end

    it 'is configurable with block' do
      expect {
        Sniffer.config do |c|
          c.enabled = true
        end
      }.to change { Sniffer.config.enabled }.from(false).to(true)
    end
  end

  it 'theadsafe' do
    expect do
      Thread.new do
        Sniffer.enable!
        expect(Sniffer.enabled?).to be_truthy
      end.join
    end.not_to change { Sniffer.enabled? }
  end
end
