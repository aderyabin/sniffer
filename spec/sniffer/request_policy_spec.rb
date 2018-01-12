# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sniffer::RequestPolicy do
  context '#call' do
    subject { described_class.call(Sniffer::DataItem::Request.new(host: 'evilmartians.com', headers: { 'user-agent': 'Ruby' }, body: "author=Matz", method: "GET", port: 80)) }

    context 'whitelist' do
      it 'is true with empty whitelist' do
        Sniffer.config.url_whitelist = nil

        expect(subject).to eq(true)
      end

      it 'is true if request whitelisted' do
        Sniffer.config.url_whitelist = /evilmartians.com/

        expect(subject).to eq(true)
      end

      it 'is false if whitelisted other host' do
        Sniffer.config.url_whitelist = /acme.com/

        expect(subject).to eq(false)
      end

      it 'works with strings' do
        Sniffer.config.url_whitelist = 'evilmartians.com'

        expect(subject).to eq(true)
      end
    end

    context 'blacklist' do
      it 'is true with empty blacklist' do
        Sniffer.config.url_blacklist = nil

        expect(subject).to eq(true)
      end

      it 'is false if request blacklisted' do
        Sniffer.config.url_blacklist = /evilmartians.com/

        expect(subject).to eq(false)
      end

      it 'is true if request whitelisted and blacklisted' do
        Sniffer.config.url_whitelist = /evilmartians.com/
        Sniffer.config.url_blacklist = /evilmartians.com/

        expect(subject).to eq(true)
      end

      it 'is true if request blacklisted other host' do
        Sniffer.config.url_blacklist = /acme.com/

        expect(subject).to eq(true)
      end

      it 'works with strings' do
        Sniffer.config.url_blacklist = 'evilmartians.com'

        expect(subject).to eq(false)
      end
    end
  end
end
