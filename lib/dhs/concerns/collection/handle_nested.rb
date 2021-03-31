# frozen_string_literal: true

require 'active_support'

class DHS::Collection < DHS::Proxy

  # Handles pontentially (deep-)nested collections
  #   Examples:
  #     [ { name: 'Steve '} ]
  #     { items: [ { name: 'Steve' } ] }
  #     { response: { business: [ { name: 'Steve' } ] } }
  module HandleNested
    extend ActiveSupport::Concern

    delegate :access, :nest, :concat, to: :class

    module ClassMethods
      # Access potentially nested collection of items
      def access(input:, record: nil)
        input.dig(*items_key(record))
      end

      # Initializes nested collection
      def nest(input:, value: nil, record: nil)
        input[items_key(record)] = value
      end

      # Concats existing nested collection of items
      # with given items
      def concat(input:, items:, record: nil)
        input.dig(*items_key(record)).concat(items)
      end

      private

      # Takes configured items key to access collection of items
      # of falls back to the default key
      def items_key(record)
        record&.items_key || DHS::Record.items_key
      end
    end
  end
end
