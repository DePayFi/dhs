# frozen_string_literal: true

require 'rails_helper'

describe DHS::Data do
  before do
    class Record < DHS::Record
      endpoint 'http://depay.fi/records'
    end
  end

  let(:item) do
    {
      customer: {
        addresses: [
          {
            first_line: 'Bachstr. 6'
          }
        ]
      }
    }
  end

  let(:data) do
    DHS::Data.new(
      {
        href: 'http://depay.fi/records',
        items: [item]
      }, nil, Record
    )
  end

  it 'provides the information which type of proxy data ist' do
    expect(data.collection?).to eq true
    expect(data.first.item?).to eq true
    expect(data.first.customer.item?).to eq true
    expect(data.first.customer.addresses.collection?).to eq true
    expect(data.first.customer.addresses.first.item?).to eq true
  end
end
