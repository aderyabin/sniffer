# frozen_string_literal: true

require_relative "entry"

module Sniffer
  # Middleware is code configured to run before/after
  # storing sniffed request/response
  # To add middleware
  #
  # Sniffer.middleware do |chain|
  #   chain.add MyHook
  # end
  #
  # class MyHook
  #   def call(data_item)
  #     puts "Before work"
  #     yield
  #     puts "After work"
  #   end
  # end
  module Middleware
    # Stores all the middleware configs
    class Chain
      include Enumerable

      def entries
        @entries ||= []
      end

      def each(&block)
        entries.each(&block)
      end

      def add(klass, *args)
        entries.push(Entry.new(klass, *args))
      end

      def remove(klass)
        entries.delete_if { |entry| entry.klass == klass }
      end

      def invoke(*args)
        chain = map(&:make_new).dup
        traverse_chain = lambda do
          if chain.empty?
            yield
          else
            chain.shift.call(*args, &traverse_chain)
          end
        end
        traverse_chain.call
      end
    end
  end
end
