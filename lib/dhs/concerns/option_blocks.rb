# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/module/attribute_accessors_per_thread'

module DHS
  module OptionBlocks
    extend ActiveSupport::Concern

    class CurrentOptionBlock
      thread_mattr_accessor :options
    end

    module ClassMethods
      def options(options, &block)
        CurrentOptionBlock.options = options
        block.call
      ensure
        CurrentOptionBlock.options = nil
      end
    end
  end
end
