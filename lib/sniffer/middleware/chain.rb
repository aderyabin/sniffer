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
  #   def request(data_item)
  #     puts "Before request work"
  #     yield
  #     puts "After request work"
  #   end
  #
  #   def response(data_item)
  #     puts "Before response work"
  #     yield
  #     puts "After response work"
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

      def invoke_request(*args)
        chain = map(&:make_new).dup
        traverse_chain = lambda do
          if chain.empty?
            yield
          else
            chain.shift.request(*args, &traverse_chain)
          end
        end
        traverse_chain.call
      end

      def invoke_response(*args)
        chain = map(&:make_new).dup
        traverse_chain = lambda do
          if chain.empty?
            yield
          else
            chain.shift.response(*args, &traverse_chain)
          end
        end
        traverse_chain.call
      end
    end
  end
end
