# frozen_string_literal: true

require 'active_support'

class DHS::Record

  module Tracing
    extend ActiveSupport::Concern

    module ClassMethods
      # Needs to be called directly from the first method (level) within DHS
      def trace!(options = {})
        return options unless DHS.config.trace

        (options || {}).tap do |options|
          source = caller.detect do |source|
            !source.match?(%r{/lib/dhs}) && !source.match?(%r{internal\:})
          end
          options[:source] = source
        end
      end
    end
  end
end
