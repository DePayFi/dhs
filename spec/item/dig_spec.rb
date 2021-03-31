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
      local_entry: {
        local_entry_id: 'ABC123'
      }
    }
  end

  let(:item) do
    DHS::Data.new(json, nil, Record)
  end

  it 'is possible to dig data' do
    expect(
      item.dig(:local_entry, :local_entry_id)
    ).to eq 'ABC123'
  end
end
