# frozen_string_literal: true

require 'active_support'

class DHS::Data

  module Becomes
    extend ActiveSupport::Concern

    def becomes(klass, options = {})
      return self if self.instance_of?(klass) && !is_a?(DHS::Data)
      data = DHS::Data.new(_raw, _parent, klass)
      data.errors = options[:errors] if options[:errors]
      data.warnings = options[:warnings] if options[:warnings]
      klass.new(data)
    end
  end
end
