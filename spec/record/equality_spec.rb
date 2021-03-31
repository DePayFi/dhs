# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'equality' do
    before do
      class Record < DHS::Record
        endpoint 'http://depay.fi/records'
      end
    end

    let(:raw) do
      { name: 'Steve' }
    end

    def record
      DHS::Record.new DHS::Data.new(raw, nil, Record)
    end

    it 'is equal when two data objects share the same raw data' do
      expect(
        record
      ).to eq record
    end
  end
end
