# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  let(:next_parameter) do
    { next: { href: 'http://example.com/users?from_user_id=100&limit=100' } }
  end
  let(:data_hash) { { items: 98.times.map { { foo: 'bar' } }, limit: 10 }.merge(next_parameter) }

  let(:data) do
    DHS::Data.new(data_hash, nil, DHS::Record)
  end

  let(:pagination) { DHS::Pagination::Link.new(data) }

  it 'responds to pages_left' do
    expect(pagination.pages_left).to eq(1)
  end

  it 'responds to pages_left?' do
    expect(pagination.pages_left?).to be true
  end

  context 'when there is no next' do
    let(:next_parameter) { {} }

    it 'responds to pages_left' do
      expect(pagination.pages_left).to eq(0)
    end

    it 'responds to pages_left?' do
      expect(pagination.pages_left?).to be false
    end
  end
end
