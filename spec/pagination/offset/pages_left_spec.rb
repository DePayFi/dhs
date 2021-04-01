# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  let(:offset) { 0 }
  let(:data_hash) { { items: 98.times.map { { foo: 'bar' } }, total: 98, offset: offset, limit: 10 } }

  let(:data) do
    DHS::Data.new(data_hash, nil, DHS::Record)
  end

  let(:pagination) { DHS::Pagination::Offset.new(data) }

  it 'responds to pages_left' do
    expect(pagination.pages_left).to eq(9)
  end

  context 'when there is no offset' do
    let(:offset) { nil }

    it 'responds to pages_left' do
      expect(pagination.pages_left).to eq(9)
    end
  end
end
