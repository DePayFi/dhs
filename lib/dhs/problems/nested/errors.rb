# frozen_string_literal: true

module DHS::Problems
  module Nested
    class Errors < DHS::Problems::Errors
      include DHS::Problems::Nested::Base

      def initialize(errors, scope)
        @raw = errors
        @messages = nest(errors.messages, scope)
        @message = errors.message
        @scope = scope
      end
    end
  end
end
