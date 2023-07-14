# frozen_string_literal: true

class DHS::Pagination::NextParameter < DHS::Pagination::Base

  DEFAULT_OFFSET = nil

  def total
    data._raw.dig(*_record.items_key).count || 0
  end
  alias count total

  def self.next_offset(offset, limit)
    nil
  end

  def parallel?
    false
  end

  def pages_left?
    next_offset = data._raw.dig(*_record.pagination_key(:body))
    next_offset.present? && !next_offset.blank?
  end

  def next(current)
    next_value = current.dig(*_record.pagination_key(:body))
    return if next_value.blank? || next_value.blank?
    {
      _record.pagination_key(:parameter) => current.dig(*_record.pagination_key(:body))
    }
  end
end
