# frozen_string_literal: true

class DHS::Pagination::TotalPages < DHS::Pagination::Page

  def total
    (data._raw.dig(*_record.total_key) || 0) * limit
  end
  alias count total
end
