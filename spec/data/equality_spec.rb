# frozen_string_literal: true

require 'rails_helper'

describe DHS::Data do
  context 'equality' do
    before do
      class Record < DHS::Record
        endpoint 'http://depay.fi/records'
      end
    end

    let(:raw) do
      { name: 'Steve' }
    end

    it 'is equal when two data objects share the same raw data' do
      expect(
        DHS::Data.new(raw, nil, Record)
      ).to eq DHS::Data.new(raw, nil, Record)
    end
  end
end
