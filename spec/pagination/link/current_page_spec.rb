# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  let(:data_hash) do
    { items: 98.times.map { { foo: 'bar' } }, limit: 10, next: { href: 'http://example.com/users?from_user_id=100&limit=100' } }
  end

  let(:data) do
    DHS::Data.new(data_hash, nil, DHS::Record)
  end

  let(:pagination) { DHS::Pagination::Link.new(data) }

  it 'responds to parallel?' do
    expect(pagination.current_page).to be nil
  end
end
