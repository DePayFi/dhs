# frozen_string_literal: true

require 'active_support'

class DHS::Record

  module Create
    extend ActiveSupport::Concern

    module ClassMethods
      def create(data = {}, options = nil)
        record = new(data)
        record.save(options)
        record
      end

      def create!(data = {}, options = nil)
        record = new(data)
        record.save!(options)
        record
      end
    end
  end
end
