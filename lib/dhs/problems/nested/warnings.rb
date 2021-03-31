# frozen_string_literal: true

module DHS::Problems
  module Nested
    class Warnings < DHS::Problems::Warnings
      include DHS::Problems::Nested::Base

      def initialize(warnings, scope)
        @raw = warnings.raw
        @messages = nest(warnings.messages, scope)
        @scope = scope
      end
    end
  end
end
