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
        address: {
          first_line: 'Bachstr. 6'
        }
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

  it 'possible to navigate the parent' do
    expect(
      data.first.customer.address.parent
    ).to eq data.first.customer
    expect(
      data.first.customer.address.parent.parent
    ).to eq data.first
  end
end
