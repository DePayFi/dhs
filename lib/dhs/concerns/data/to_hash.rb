# frozen_string_literal: true

require 'active_support'

class DHS::Data

  module ToHash
    extend ActiveSupport::Concern

    included do
      delegate :to_h, :to_hash, to: :_raw, allow_nil: true
    end
  end
end
