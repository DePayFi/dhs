# frozen_string_literal: true

require 'active_support'

class DHS::Record

  module Batch
    extend ActiveSupport::Concern

    module ClassMethods
      # Process single entries fetched in batches
      def find_each(options = {})
        find_in_batches(options) do |records|
          records.each do |record|
            item = DHS::Item.new(record)
            yield new(DHS::Data.new(item, records._data, self))
          end
        end
      end

      # Process batches of entries
      def find_in_batches(options = {})
        raise 'No block given' unless block_given?
        options = options.dup
        start = options[:start] || self.pagination_class::DEFAULT_OFFSET
        batch_size = options.delete(:batch_size) || self.pagination_class::DEFAULT_LIMIT
        loop do # as suggested by Matz
          options = options.dup
          options[:params] = (options[:params] || {}).merge(limit_key(:parameter) => batch_size, pagination_key(:parameter) => start)
          data = request(options)
          pagination = self.pagination(data)
          batch_size = pagination.limit
          left = pagination.pages_left
          yield new(data)
          break if left <= 0
          start = pagination.next_offset
        end
      end
    end
  end
end
