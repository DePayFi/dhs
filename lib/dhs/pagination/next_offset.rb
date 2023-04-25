# frozen_string_literal: true

class DHS::Pagination::NextOffset < DHS::Pagination::Base

  DEFAULT_OFFSET = 0

  def total
    data._raw.dig(*_record.items_key).count || 0
  end
  alias count total

  def parallel?
    false
  end

  def pages_left?
    next_offset = data._raw.dig(*_record.pagination_key(:body))
    next_offset.present? && !next_offset.zero?
  end

  def next(current)
    next_value = current.dig(*_record.pagination_key(:body))
    return if next_value.blank? || next_value.zero?
    {
      _record.pagination_key(:parameter) => current.dig(*_record.pagination_key(:body))
    }
  end
end
