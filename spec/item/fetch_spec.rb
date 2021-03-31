# frozen_string_literal: true

require 'rails_helper'

describe DHS::Item do
  before do
    class Record < DHS::Record
      endpoint '{+datastore}/records'
    end
  end

  let(:json) do
    {
      local_entry_id: 'ABC123'
    }
  end

  let(:item) do
    DHS::Data.new(json, nil, Record)
  end

  it 'is possible to fetch data' do
    expect(
      item.fetch(:local_entry_id)
    ).to eq 'ABC123'
  end

  context 'empty data' do
    let(:json) do
      {}
    end

    it 'is possible to get a default when fetched data is nil' do
      expect(
        item.fetch(:local_entry_id, 'DEFAULT')
      ).to eq 'DEFAULT'
    end
  end
end
