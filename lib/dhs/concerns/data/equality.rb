# frozen_string_literal: true

require 'active_support'

class DHS::Data

  module Equality
    extend ActiveSupport::Concern

    def ==(other)
      _raw == other.try(:_raw)
    end
  end
end
