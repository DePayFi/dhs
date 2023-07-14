# frozen_string_literal: true

require 'active_support'

class DHS::Record

  module Pagination
    extend ActiveSupport::Concern
    # Kaminari-Interface
    delegate :current_page, :first_page, :last_page, :prev_page, :next_page, :limit_value, :total_pages, to: :_pagination

    def paginated?(raw = nil)
      self.class.paginated?(raw || _raw)
    end

    def _pagination
      self.class.pagination(_data)
    end

    module ClassMethods
      def pagination_class
        case pagination_strategy.to_sym
        when :page
          DHS::Pagination::Page
        when :total_pages
          DHS::Pagination::TotalPages
        when :offset_page
          DHS::Pagination::OffsetPage
        when :start
          DHS::Pagination::Start
        when :link
          DHS::Pagination::Link
        when :next_offset
          DHS::Pagination::NextOffset
        when :next_parameter
          DHS::Pagination::NextParameter
        else
          DHS::Pagination::Offset
        end
      end

      def pagination(data)
        pagination_class.new(data)
      end

      # Checks if given raw is paginated or not
      def paginated?(raw)
        raw.is_a?(Hash) && (
          raw.dig(*total_key).present? ||
          raw.dig(*limit_key(:body)).present? ||
          raw.dig(*pagination_key(:body)).present?
        )
      end
    end
  end
end
