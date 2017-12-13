# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sniffer do
  it "has a version number" do
    expect(Sniffer::VERSION).not_to be nil
  end

  describe ".disable!" do
    it 'disables sniffer' do
      Sniffer.current.enable!
      expect {
        Sniffer.current.disable!
      }.to change { Sniffer.current.enabled? }.to(false)
    end
  end

  describe ".enable!" do
    it 'enables sniffer' do
      expect {
        Sniffer.current.enable!
      }.to change { Sniffer.current.enabled? }.to(true)
    end
  end

  describe ".data" do
    it "is empty by default" do
      expect(Sniffer.current.data).to be_empty
    end
  end

  describe ".store" do
    it 'stores data items' do
      data_item = Sniffer::DataItem.new
      expect {
        Sniffer.current.store(data_item)
      }.to change { Sniffer.current.data.include?(data_item) }.to(true)
    end

    it 'stores no more than capacity if set (and rotate by default)' do
      Sniffer.current.config.store = { capacity: 1 }

      first = Sniffer::DataItem.new
      Sniffer.current.store(first)
      expect(Sniffer.current.data.include?(first)).to be_truthy

      second = Sniffer::DataItem.new
      Sniffer.current.store(second)
      expect(Sniffer.current.data.include?(first)).to be_falsey
      expect(Sniffer.current.data.include?(second)).to be_truthy
    end

    it 'do not stores data without rotation' do
      Sniffer.current.config.store = { capacity: 1, rotate: false }

      first = Sniffer::DataItem.new
      Sniffer.current.store(first)
      second = Sniffer::DataItem.new
      Sniffer.current.store(second)

      expect(Sniffer.current.data.include?(first)).to be_truthy
      expect(Sniffer.current.data.include?(second)).to be_falsey
    end
  end

  context ".clear!" do
    it 'clears data' do
      Sniffer.current.store(Sniffer::DataItem.new)

      expect {
        Sniffer.current.clear!
      }.to change { Sniffer.current.data.empty? }.to(true)
    end
  end

  context "config" do
    it 'is configurable' do
      expect {
        Sniffer.current.config.enabled = true
      }.to change { Sniffer.current.config.enabled }.from(false).to(true)
    end

    it 'is configurable with block' do
      expect {
        Sniffer.current.config do |c|
          c.enabled = true
        end
      }.to change { Sniffer.current.config.enabled }.from(false).to(true)
    end
  end

  it 'theadsafe' do
    expect do
      Thread.new do
        Sniffer.current.enable!
        expect(Sniffer.current.enabled?).to be_truthy
      end.join
    end.not_to change { Sniffer.current.enabled? }
  end
end
