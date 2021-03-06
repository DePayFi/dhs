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
      key: 'value'
    }
  end

  let(:item) do
    DHS::Data.new(json, nil, Record)
  end

  it 'is possible to map' do
    mapped_data = item.map do |key, value|
      { value => key }
    end
    expect(mapped_data).to eq([{ 'value' => :key }])
  end

  context 'nested' do
    let(:json) do
      {
        languages: {
          de: { key: 'german value' },
          en: { key: 'english value' }
        }
      }
    end

    it 'also maps nested data' do
      mapped_data = item.languages.map do |_language, value|
        value[:key]
      end
      expect(mapped_data).to eq(['german value', 'english value'])
    end
  end
end
