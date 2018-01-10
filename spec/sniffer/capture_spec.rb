# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Sniffer::Capture' do
  let(:capture) { Sniffer.new }

  describe ".disable!" do
    it 'disables sniffer' do
      capture.enable!
      expect {
        capture.disable!
      }.to change { capture.enabled? }.to(false)
    end
  end

  describe ".enable!" do
    it 'enables sniffer' do
      expect {
        capture.enable!
      }.to change { capture.enabled? }.to(true)
    end
  end

  describe ".data" do
    it "is empty by default" do
      expect(capture.data).to be_empty
    end
  end

  describe ".store" do
    it 'stores data items' do
      data_item = Sniffer::DataItem.new
      expect {
        capture.store(data_item)
      }.to change { capture.data.include?(data_item) }.to(true)
    end

    it 'stores no more than capacity if set (and rotate by default)' do
      capture = Sniffer.new(store: { capacity: 1 })

      first = Sniffer::DataItem.new
      capture.store(first)
      expect(capture.data.include?(first)).to be_truthy

      second = Sniffer::DataItem.new
      capture.store(second)
      expect(capture.data.include?(first)).to be_falsey
      expect(capture.data.include?(second)).to be_truthy
    end

    it 'do not stores data without rotation' do
      capture = Sniffer.new(store: { capacity: 1, rotate: false })

      first = Sniffer::DataItem.new
      capture.store(first)
      second = Sniffer::DataItem.new
      capture.store(second)

      expect(capture.data.include?(first)).to be_truthy
      expect(capture.data.include?(second)).to be_falsey
    end
  end

  context ".clear!" do
    capture = Sniffer.new
    it 'clears data' do
      capture.store(Sniffer::DataItem.new)

      expect {
        capture.clear!
      }.to change { capture.data.empty? }.to(true)
    end
  end

  context "config" do
    it 'is configurable' do
      capture = Sniffer.new
      expect {
        capture.config.enabled = true
      }.to change { capture.config.enabled }.from(false).to(true)
    end

    it 'is configurable with block' do
      capture = Sniffer.new
      expect {
        capture.config do |c|
          c.enabled = true
        end
      }.to change { capture.config.enabled }.from(false).to(true)
    end
  end
end
