# frozen_string_literal: true

require 'rails_helper'

describe DHS::Record do
  context 'options' do
    before do
      class Record < DHS::Record
        endpoint 'http://depay.fi/records'
      end
    end

    let(:raw) do
      { options: { criticality: :high } }
    end

    def record
      DHS::Record.new DHS::Data.new(raw, nil, Record)
    end

    it 'is possible to fetch data from a key called options from an instance' do
      expect(record.options.criticality).to eq :high
    end
  end
end
