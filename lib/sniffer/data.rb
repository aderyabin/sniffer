# frozen_string_literal: true

module Sniffer
  # Data class stores the data and controls capacity
  class Data < Array
    attr_reader :sniffer
    def initialize(sniffer)
      @sniffer = sniffer
    end

    def store(data_item)
      return unless config.store

      if config.rotate?
        rotate(data_item)
      else
        push(data_item) unless overflow?
      end
    end

    private

    def rotate(data_item)
      shift if overflow?
      push(data_item)
    end

    def overflow?
      config.capacity? && length >= config.capacity
    end

    def config
      Sniffer.current.config
    end
  end
end
