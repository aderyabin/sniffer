# frozen_string_literal: true

module Sniffer
  # Data class stores the data and controls capacity
  class Data < Array
    def store(data_item)
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
      Sniffer.config
    end
  end
end
