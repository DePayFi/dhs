# frozen_string_literal: true

require 'active_support'

class DHS::Record

  module First
    extend ActiveSupport::Concern

    module ClassMethods
      def first(options = nil)
        find_by({}, trace!(options))
      end

      def first!(options = nil)
        find_by!({}, trace!(options))
      end
    end
  end
end
