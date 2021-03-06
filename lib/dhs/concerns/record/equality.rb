# frozen_string_literal: true

require 'active_support'

class DHS::Record

  module Equality
    extend ActiveSupport::Concern

    def ==(other)
      _raw == other.try(:_raw)
    end
  end
end
