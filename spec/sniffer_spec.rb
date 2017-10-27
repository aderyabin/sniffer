# frozen_string_literal: true

require "spec_helper"

RSpec.describe Sniffer do
  it "has a version number" do
    expect(Sniffer::VERSION).not_to be nil
  end

  describe ".disable!" do
    it 'disables sniffer' do
      Sniffer.config.enabled = true
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
  end

  context ".clear!" do
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
end
