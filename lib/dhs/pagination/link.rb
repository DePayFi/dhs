# frozen_string_literal: true

class DHS::Pagination::Link < DHS::Pagination::Base
  def total
    data._raw.dig(*_record.items_key).count || 0
  end

  alias count total

  def next(current)
    current.dig(:next, :href)
  end

  def pages_left
    pages_left? ? 1 : 0
  end

  def pages_left?
    data._raw[:next].present?
  end

  def parallel?
    false
  end
end
